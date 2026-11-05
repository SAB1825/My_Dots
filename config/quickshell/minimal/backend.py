"""Command adapter for the Quickshell UI. Every operation returns structured results."""
import concurrent.futures
import json
import os
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import theming

STATE = pathlib.Path(os.environ.get("XDG_STATE_HOME", pathlib.Path.home() / ".local/state")) / "quickshell/minimal"


def call(args, timeout=10):
    try:
        result = subprocess.run(args, capture_output=True, text=True, timeout=timeout, env={**os.environ, "LC_ALL": "C"})
        # bluetoothctl occasionally prints failure text while returning success.
        output = result.stdout.strip()
        failed = result.returncode != 0 or any(v in output for v in ("Failed to ", "No default controller available", "not available"))
        return {"ok": not failed, "output": output,
                "error": (result.stderr.strip() or output or f"Command exited with {result.returncode}") if failed else ""}
    except FileNotFoundError:
        return {"ok": False, "output": "", "error": f"{args[0]} is not installed"}
    except subprocess.TimeoutExpired:
        return {"ok": False, "output": "", "error": f"{args[0]} timed out"}


def status():
    commands = [["nmcli", "-t", "--escape", "no", "-f", "TYPE,STATE,CONNECTION", "device", "status"],
                ["nmcli", "radio", "wifi"], ["bluetoothctl", "show"]]
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        devices, wifi, bluetooth = list(pool.map(call, commands))
    connections = [line.split(":", 2)[2] for line in devices["output"].splitlines() if line.startswith("wifi:connected:")]
    return {"network": connections[0] if connections else "Not connected", "wifi": wifi["output"] == "enabled",
            "wifiAvailable": devices["ok"] and any(line.startswith("wifi:") for line in devices["output"].splitlines()),
            "wifiError": devices["error"] or wifi["error"], "bluetooth": "Powered: yes" in bluetooth["output"],
            "bluetoothAvailable": bluetooth["ok"] and "Controller " in bluetooth["output"],
            "bluetoothError": bluetooth["error"], "cava": bool(shutil.which("cava"))}


def nm_fields(line):
    """Split nmcli escaped terse fields, including SSIDs containing colons."""
    fields, current, escaped = [], "", False
    for char in line:
        if escaped:
            current += char
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            fields.append(current)
            current = ""
        else:
            current += char
    fields.append(current)
    return fields


def battery(folder=pathlib.Path("/sys/class/power_supply")):
    packs = []
    for device in folder.glob("*"):
        try:
            if (device / "type").read_text().strip() != "Battery":
                continue
            packs.append({"percent": int((device / "capacity").read_text()),
                          "state": (device / "status").read_text().strip()})
        except (OSError, ValueError):
            continue
    return {"available": bool(packs),
            "percent": round(sum(p["percent"] for p in packs) / len(packs)) if packs else 0,
            "state": packs[0]["state"] if packs else "No battery"}


def networks():
    result = call(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list", "--rescan", "auto"], 20)
    items, seen = [], set()
    for line in result["output"].splitlines():
        fields = nm_fields(line)
        if len(fields) != 4 or not fields[1] or fields[1] in seen:
            continue
        seen.add(fields[1])
        items.append({"active": fields[0] == "*", "ssid": fields[1], "signal": fields[2], "security": fields[3]})
    return {"ok": result["ok"], "error": result["error"], "items": items}


def bluetooth_devices(scan=False):
    if scan:
        call(["bluetoothctl", "--timeout", "6", "scan", "on"], 10)
    result = call(["bluetoothctl", "devices"])
    items = []
    for line in result["output"].splitlines():
        match = re.match(r"Device ([0-9A-Fa-f:]{17}) (.+)", line)
        if not match:
            continue
        address, name = match.groups()
        info = call(["bluetoothctl", "info", address])["output"]
        items.append({"address": address, "name": name, "connected": "Connected: yes" in info,
                      "paired": "Paired: yes" in info})
    return {"ok": result["ok"], "error": result["error"], "items": items}


def device_action(data):
    action = data.get("action")
    if action == "wifi-connect":
        ssid = data.get("ssid", "")
        if not ssid:
            return {"ok": False, "error": "Choose a network"}
        password = data.get("password", "")
        if password:
            # nmcli --ask accepts the secret over stdin, outside the process argument list.
            try:
                result = subprocess.run(["nmcli", "--ask", "--wait", "25", "device", "wifi", "connect", ssid],
                                        input=password + "\n", capture_output=True, text=True, timeout=30, env={**os.environ, "LC_ALL": "C"})
                return {"ok": result.returncode == 0, "error": "" if result.returncode == 0 else (result.stderr.strip() or "Connection failed")}
            except subprocess.TimeoutExpired:
                return {"ok": False, "error": "Connection timed out"}
            except FileNotFoundError:
                return {"ok": False, "error": "nmcli is not installed"}
        return call(["nmcli", "--wait", "25", "device", "wifi", "connect", ssid], 30)
    if action == "wifi-disconnect":
        result = call(["nmcli", "-t", "-f", "DEVICE,TYPE", "device", "status"])
        for line in result["output"].splitlines():
            fields = nm_fields(line)
            if len(fields) == 2 and fields[1] == "wifi":
                return call(["nmcli", "device", "disconnect", fields[0]])
        return {"ok": False, "error": result["error"] or "No Wi-Fi adapter"}
    if action in {"bt-connect", "bt-disconnect", "bt-pair"}:
        address = data.get("address", "")
        if not re.fullmatch(r"[0-9A-Fa-f]{2}(?::[0-9A-Fa-f]{2}){5}", address):
            return {"ok": False, "error": "Invalid Bluetooth address"}
        if action == "bt-pair":
            paired = call(["bluetoothctl", "--agent", "NoInputNoOutput", "--timeout", "25", "pair", address], 30)
            if not paired["ok"]:
                return {"ok": False, "error": paired["error"] + " · Devices requiring a PIN must be paired in Bluetooth settings."}
            trusted = call(["bluetoothctl", "trust", address])
            if not trusted["ok"]:
                return trusted
            return call(["bluetoothctl", "--timeout", "20", "connect", address], 25)
        return call(["bluetoothctl", "--timeout", "20", "connect" if action == "bt-connect" else "disconnect", address], 25)
    return {"ok": False, "error": "Unknown action"}


def main():
    mode = sys.argv[1]
    if mode == "theme-refresh":
        return theming.refresh_integrations()
    if mode == "theme-list":
        return theming.choices()
    if mode == "theme-apply":
        return theming.apply_theme(sys.argv[2])
    if mode == "theme-sync":
        return theming.sync()
    if mode == "status":
        result = status()
        result["battery"] = battery()
        return result
    if mode == "networks":
        return networks()
    if mode == "bluetooth-devices":
        return bluetooth_devices("--scan" in sys.argv)
    if mode == "device-action":
        return device_action(json.load(sys.stdin))
    if mode == "wallpapers":
        folder = pathlib.Path.home() / "Pictures/Wallpapers"
        return [{"name": p.stem, "path": str(p), "url": p.as_uri()} for p in sorted(folder.rglob("*"))
                if p.is_file() and p.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp", ".gif", ".bmp"}]
    if mode == "palette":
        return theming.apply_theme("dynamic", sys.argv[2])
    if mode == "wallpaper":
        return theming.apply_wallpaper(sys.argv[2])
    if mode == "action":
        domain, value = sys.argv[2:4]
        if domain == "wifi" and value in {"on", "off"}:
            return call(["nmcli", "radio", "wifi", value])
        if domain == "bluetooth" and value in {"on", "off"}:
            return call(["bluetoothctl", "--timeout", "8", "power", value])
        return {"ok": False, "error": "Unknown action"}
    if mode == "cava":
        if not shutil.which("cava"):
            return None
        STATE.mkdir(parents=True, exist_ok=True)
        config = STATE / "cava.conf"
        config.write_text("[general]\nbars = 16\nframerate = 30\n[input]\nmethod = pulse\nsource = auto\n[output]\nmethod = raw\nraw_target = /dev/stdout\ndata_format = ascii\nascii_max_range = 100\n")
        # Replace the helper so Quickshell owns CAVA's lifetime directly.
        os.execvp("cava", ["cava", "-p", str(config)])
    return {"ok": False, "error": "Unknown operation"}


if __name__ == "__main__":
    response = main()
    if response is not None:
        print(json.dumps(response))
