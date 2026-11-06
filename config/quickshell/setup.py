#!/usr/bin/env python3
"""Prepare shell helpers and optional Hyprland integration."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent
SHELL = ROOT
HOME = Path.home()
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', HOME / '.config'))
HYPR = CONFIG / 'hypr'
BACKUP = ROOT / 'backups' / datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f')
changes = []


def put(path, data, executable=False):
    path = Path(path)
    if path.exists() and path.read_bytes() == data:
        return
    if path.is_symlink():
        raise RuntimeError(f'Refusing to replace symlink: {path}')
    old = None
    if path.exists():
        old = BACKUP / str(len(changes))
        old.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, old)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    if executable:
        path.chmod(0o755)
    changes.append({'path': str(path), 'backup': str(old) if old else None,
                    'sha256': hashlib.sha256(data).hexdigest()})
    BACKUP.mkdir(parents=True, exist_ok=True)
    (BACKUP / 'manifest.json').write_text(json.dumps(changes, indent=2) + '\n')


def text(path, value, executable=False):
    put(path, value.encode(), executable)


def run(*cmd):
    subprocess.run(cmd, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--activate', action='store_true', help='also install shell shortcuts and start the shell')
    args = parser.parse_args()
    required = ['cargo', 'rustc', 'matugen', 'qs', 'magick', 'jq', 'hyprlock', 'notify-send', 'luac']
    missing = [name for name in required if not shutil.which(name)]
    if missing:
        raise SystemExit('Install dependencies first. Missing: ' + ', '.join(missing))
    # Build before deploying anything. Cargo.lock pins the upstream dependencies.
    target = ROOT / 'build'
    run('cargo', 'build', '--release', '--locked', '--manifest-path',
        str(ROOT / 'src/islandd/Cargo.toml'), '--target-dir', str(target))
    put(HOME / '.local/bin/islandd', (target / 'release/islandd').read_bytes(), True)
    for name in ['hyprdo', 'qs-solo', 'aulactl']:
        put(HOME / '.local/bin' / name, (ROOT / 'bin' / name).read_bytes(), True)
    # Copy only helpers used by the shell, excluding upstream update/install machinery.
    for folder in ['tools', 'lock', 'clipboard', 'capture', 'print']:
        source = ROOT / 'config/hypr/scripts' / folder
        for src in source.iterdir():
            if src.is_file():
                data = src.read_text()
                # Upstream reorganized these scripts but left two old call sites.
                data = data.replace('$CONFIG_DIR/scripts/lock-prepare.sh', '$CONFIG_DIR/scripts/lock/lock-prepare.sh')
                data = data.replace('$CONF/scripts/lock.sh', '$CONF/scripts/lock/lock.sh')
                if src.name == 'lock.sh':
                    data = data.replace('matugen image "$wallpaper"',
                                        'matugen --config "$HOME/.config/quickshell/matugen-shell.toml" image "$wallpaper"')
                text(HYPR / 'scripts' / folder / src.name, data, True)
    for name in ['audio/mic-target.sh', 'system/procs.py']:
        put(HYPR / 'scripts' / name, (ROOT / 'config/hypr/scripts' / name).read_bytes(), True)
    # Use the current session bus, which is already available to the shell.
    text(HYPR / 'scripts/notify/dbus-notify.sh', '#!/bin/sh\nexec notify-send "$@"\n', True)
    setter = (ROOT / 'config/hypr/scripts/wallpaper/set-wallpaper.sh').read_text()
    setter = setter.replace('matugen image "$WALLPAPER"',
                            'matugen --config "$HOME/.config/quickshell/matugen-shell.toml" image "$WALLPAPER"')
    # SDDM synchronization belongs to the full desktop installer.
    setter = setter.split('\nSDDM_SYNC=')[0] + '\n'
    text(HYPR / 'scripts/wallpaper/set-wallpaper.sh', setter, True)
    put(HYPR / 'scripts/wallpaper/wallpaper-index.sh',
        (ROOT / 'config/hypr/scripts/wallpaper/wallpaper-index.sh').read_bytes(), True)
    put(CONFIG / 'cava/config-bar', (ROOT / 'config/cava/config-bar').read_bytes())
    (HYPR / 'config').mkdir(parents=True, exist_ok=True)
    # Choose Quickshell's lock; hyprlock supplies its PAM authentication config.
    text(HOME / '.local/state/hypr/lock-choice', 'qs\n')
    wallpaper = ''
    if (HYPR / 'current-wallpaper').exists():
        wallpaper = (HYPR / 'current-wallpaper').read_text().strip()
    if not Path(wallpaper).is_file():
        candidates = sorted(p for p in (HOME / 'Pictures/Wallpapers').glob('*')
                            if p.suffix.lower() in ('.png', '.jpg', '.jpeg', '.webp'))
        wallpaper = str(candidates[0]) if candidates else ''
    if wallpaper:
        text(HYPR / 'current-wallpaper', wallpaper + '\n')
        run('matugen', '--config', str(ROOT / 'matugen-shell.toml'), 'image', wallpaper,
            '--mode', 'dark', '--type', 'scheme-content', '--prefer', 'saturation')
    else:
        run('matugen', '--config', str(ROOT / 'matugen-shell.toml'), 'color', 'hex', '#feb879')
    # Generate the sounds bundled as Python synthesis code in the upstream repo.
    run('python3', str(ROOT / 'config/hypr/scripts/theme/gen-notify-sounds.py'))
    run('python3', str(ROOT / 'timer-sounds.py'))
    put(CONFIG / 'pipewire/pipewire.conf.d/99-shell-eq.conf',
        (ROOT / 'config/pipewire/pipewire.conf.d/99-shell-eq.conf').read_bytes())
    if args.activate:
        # Main Hyprland modules are versioned alongside the shell.
        put(HYPR / 'modules/shell.lua', (ROOT / 'shell.lua').read_bytes())
        run('luac', '-p', str(HYPR / 'modules/autostart.lua'), str(HYPR / 'modules/binds.lua'),
            str(HYPR / 'modules/variables.lua'), str(HYPR / 'modules/shell.lua'))
        run('hyprctl', 'reload')
        subprocess.run(['pkill', '-x', 'dunst'], check=False)
        env = os.environ.copy()
        env['PATH'] = str(HOME / '.local/bin') + ':' + env['PATH']
        subprocess.run([str(ROOT / 'start.sh')], env=env, check=True)
    print(f'Integration ready. Changed-file backups: {BACKUP}')
    print('Shell integration is ready.')


if __name__ == '__main__':
    main()
