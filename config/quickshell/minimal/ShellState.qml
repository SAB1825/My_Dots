import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

Scope {
    id: root
    property string panel: ""
    property bool barVisible: true
    property string panelScreen: ""
    property string message: ""
    property var status: ({
            network: "…",
            wifi: false,
            bluetooth: false,
            wifiAvailable: false,
            wifiError: "",
            bluetoothAvailable: false,
            bluetoothError: "",
            cava: false
        })
    property var networks: []
    property var devices: []
    readonly property bool connectionBusy: connectionList.running || connectionAction.running || deviceCommand.running
    readonly property bool wallpaperBusy: applyWall.running
    readonly property bool themeBusy: themeApply.running || applyWall.running
    property var themeOptions: []
    property var wallpapers: []
    property var levels: []
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) || Mpris.players.values[0] || null
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool audioAvailable: !!sink?.ready && !!sink?.audio
    readonly property bool playing: !!player?.isPlaying
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    function setVolume(value) {
        if (audioAvailable)
            sink.audio.volume = Math.max(0, Math.min(1, value));
        else
            message = "No audio output available";
    }
    function mute() {
        if (audioAvailable)
            sink.audio.muted = !sink.audio.muted;
        else
            message = "No audio output available";
    }
    function deviceAction(domain, value) {
        if (connectionBusy)
            return;
        message = "Updating…";
        deviceCommand.domain = domain;
        deviceCommand.value = value;
        deviceCommand.running = true;
    }
    function toggle(name, screenName) {
        const target = screenName || Hyprland.focusedMonitor?.name || Quickshell.screens[0]?.name || "";
        panel = panel === name && panelScreen === target ? "" : name;
        panelScreen = target;
        message = "";
        if (panel === "wallpapers")
            walls.running = true;
        if (panel === "themes" && !themeList.running)
            themeList.running = true;
        if (panel === "wifi" || panel === "bluetooth")
            loadConnections(false);
    }
    function execute(args) {
        Quickshell.execDetached(args);
        refresh.restart();
    }
    IpcHandler {
        target: "shell"
        function launcher(): void {
            root.toggle("launcher");
        }
        function wallpapers(): void {
            root.toggle("wallpapers");
        }
        function themes(): void {
            root.toggle("themes");
        }
        function sound(): void {
            root.toggle("sound");
        }
        function session(): void {
            root.toggle("session");
        }
        function wifi(): void {
            root.toggle("wifi");
        }
        function bluetooth(): void {
            root.toggle("bluetooth");
        }
        function calendar(): void {
            root.toggle("calendar");
        }
        function bar(): void {
            root.panel = "";
            root.barVisible = !root.barVisible;
        }
        function close(): void {
            root.panel = "";
        }
    }
    function loadConnections(scan) {
        if (connectionList.running || (panel !== "wifi" && panel !== "bluetooth"))
            return;
        connectionList.domain = panel;
        connectionList.scan = scan;
        connectionList.running = true;
    }
    function connectionRequest(data) {
        if (connectionBusy)
            return;
        message = "Working…";
        connectionAction.stdinEnabled = true;
        connectionAction.payload = JSON.stringify(data);
        connectionAction.running = true;
    }
    Process {
        id: connectionList
        property string domain: "wifi"
        property bool scan: false
        onExited: if (root.panel !== domain && (root.panel === "wifi" || root.panel === "bluetooth"))
            connectionRefresh.restart()
        command: ["python3", Quickshell.shellPath("backend.py"), domain === "wifi" ? "networks" : "bluetooth-devices"].concat(scan && domain === "bluetooth" ? ["--scan"] : [])
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (connectionList.domain === "wifi")
                        root.networks = result.items || [];
                    else
                        root.devices = result.items || [];
                    if (!result.ok && root.panel === connectionList.domain)
                        root.message = result.error;
                } catch (e) {
                    root.message = "Could not read connections";
                }
            }
        }
    }
    Process {
        id: connectionAction
        property string payload: ""
        command: ["python3", Quickshell.shellPath("backend.py"), "device-action"]
        stdinEnabled: true
        onStarted: {
            write(payload);
            stdinEnabled = false;
            payload = "";
        }
        onExited: {
            refresh.restart();
            connectionRefresh.restart();
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.message = result.ok ? "Updated" : result.error;
                } catch (e) {
                    root.message = "Connection action failed";
                }
            }
        }
    }
    Timer {
        id: connectionRefresh
        interval: 700
        onTriggered: root.loadConnections(false)
    }
    Process {
        id: deviceCommand
        property string domain
        property string value
        onExited: connectionRefresh.restart()
        command: ["python3", Quickshell.shellPath("backend.py"), "action", domain, value]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.message = result.ok ? "Updated" : result.error;
                } catch (e) {
                    root.message = "Device control failed";
                }
                refresh.restart();
            }
        }
    }
    Process {
        id: poll
        command: ["python3", Quickshell.shellPath("backend.py"), "status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.status = JSON.parse(text);
                } catch (e) {
                    console.warn(e);
                }
            }
        }
    }
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: if (!poll.running)
            poll.running = true
    }
    Timer {
        id: refresh
        interval: 500
        onTriggered: if (!poll.running)
            poll.running = true
    }
    Process {
        command: ["python3", Quickshell.shellPath("backend.py"), "theme-refresh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.warning)
                        console.warn("Theme integrations:", result.warning);
                } catch (e) {
                    console.warn("Theme integration refresh failed");
                }
            }
        }
    }
    Process {
        id: themeList
        command: ["python3", Quickshell.shellPath("backend.py"), "theme-list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.themeOptions = JSON.parse(text).items || [];
                } catch (e) {
                    root.message = "Could not read themes";
                }
            }
        }
    }
    Process {
        id: themeApply
        property string selected: "monochrome"
        command: ["python3", Quickshell.shellPath("backend.py"), "theme-apply", selected]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.message = result.ok ? (result.warning ? "Theme saved · " + result.warning : "Theme applied") : "Theme failed: " + result.error;
                } catch (e) {
                    root.message = "Theme command failed";
                }
                if (!themeList.running)
                    themeList.running = true;
            }
        }
    }
    Process {
        id: themeSync
        command: ["python3", Quickshell.shellPath("backend.py"), "theme-sync"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (root.panel === "themes" && !result.ok)
                        root.message = result.error;
                } catch (e) {
                    console.warn("Theme sync failed");
                }
            }
        }
    }
    Timer {
        interval: 15000
        running: Theme.themeId === "dynamic"
        repeat: true
        onTriggered: if (!themeApply.running && !applyWall.running && !themeSync.running)
            themeSync.running = true
    }
    Process {
        id: walls
        command: ["python3", Quickshell.shellPath("backend.py"), "wallpapers"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.wallpapers = JSON.parse(text);
                } catch (e) {
                    console.warn(e);
                }
            }
        }
    }
    Process {
        id: applyWall
        property string path
        command: ["python3", Quickshell.shellPath("backend.py"), "wallpaper", path]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.message = result.ok ? (result.warning || "Wallpaper applied") : "Could not apply wallpaper: " + result.error;
                } catch (e) {
                    root.message = "Wallpaper command failed";
                }
            }
        }
    }
    Process {
        command: ["python3", Quickshell.shellPath("backend.py"), "cava"]
        running: root.playing
        onRunningChanged: if (!running)
            root.levels = []
        stdout: SplitParser {
            onRead: data => {
                root.levels = data.split(";").filter(v => v.length).map(Number);
            }
        }
    }
    function applyWallpaper(path) {
        if (wallpaperBusy)
            return;
        applyWall.path = path;
        applyWall.running = true;
        message = "Applying…";
    }
    function applyTheme(name) {
        if (themeBusy)
            return;
        themeApply.selected = name;
        message = name === "dynamic" ? "Extracting wallpaper colors…" : "Applying theme…";
        themeApply.running = true;
    }
}
