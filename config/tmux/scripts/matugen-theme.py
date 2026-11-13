#!/usr/bin/env python3
"""Silently sync tmux with the existing Quickshell/Matugen wallpaper palette."""

import json
import os
from pathlib import Path
import re
import subprocess


def main():
    config = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")))
    cache = Path(os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache")))
    sources = [
        (config / "rice/palette.json", {
            "bg": "surface", "surface": "surface_container", "fg": "on_surface",
            "fg_dim": "on_surface_variant", "muted": "outline", "accent": "primary",
            "accent_alt": "tertiary", "accent_text": "on_primary", "error": "error",
        }),
        (cache / "matugen/colors.json", {
            "bg": "bg", "surface": "bgAlt", "fg": "fg", "fg_dim": "fgDim",
            "muted": "outline", "accent": "accent", "accent_alt": "accentAlt",
            "accent_text": "accentText", "error": "bad",
        }),
    ]
    for path, keys in sources:
        try:
            palette = json.loads(path.read_text())
            colors = {name: palette[key] for name, key in keys.items()}
            if not all(isinstance(c, str) and re.fullmatch(r"#[0-9a-fA-F]{6}", c)
                       for c in colors.values()):
                continue
            break
        except (OSError, ValueError, KeyError, TypeError):
            continue
    else:
        return

    signature = ":".join(colors.values())
    previous = subprocess.run(
        ["tmux", "show-options", "-gqv", "@matugen_palette"],
        capture_output=True, text=True,
    )
    if previous.returncode or previous.stdout.strip() == signature:
        return
    commands = [f"set -g @palette_{name} '{color}'" for name, color in colors.items()]
    commands.append(f"set -g @matugen_palette '{signature}'")
    subprocess.run(["tmux", "source-file", "-"], input="\n".join(commands) + "\n",
                   text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


if __name__ == "__main__":
    main()
