#!/usr/bin/env python3
"""Build Quickshell helpers, generate assets, and optionally start the shell."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parent
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
    parser.add_argument('--activate', action='store_true', help='also reload Hyprland and start the shell')
    args = parser.parse_args()
    required = ['cargo', 'rustc', 'matugen', 'qs', 'magick', 'jq', 'hyprlock', 'notify-send', 'luac']
    missing = [name for name in required if not shutil.which(name)]
    if missing:
        raise SystemExit('Install dependencies first. Missing: ' + ', '.join(missing))
    for path in [CONFIG / 'matugen/config.toml', HYPR / 'scripts/theme/gen-notify-sounds.py',
                 HYPR / 'modules/shell.lua']:
        if not path.is_file():
            raise SystemExit(f'Missing sibling configuration: {path}')
    # Build before deploying anything. Cargo.lock pins the upstream dependencies.
    target = ROOT / 'build'
    run('cargo', 'build', '--release', '--locked', '--manifest-path',
        str(ROOT / 'src/islandd/Cargo.toml'), '--target-dir', str(target))
    put(HOME / '.local/bin/islandd', (target / 'release/islandd').read_bytes(), True)
    for name in ['hyprdo', 'qs-solo']:
        put(HOME / '.local/bin' / name, (ROOT / 'bin' / name).read_bytes(), True)
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
        run('matugen', '--config', str(CONFIG / 'matugen/config.toml'), 'image', wallpaper,
            '--mode', 'dark', '--type', 'scheme-content', '--prefer', 'saturation')
    else:
        run('matugen', '--config', str(CONFIG / 'matugen/config.toml'), 'color', 'hex', '#feb879')
    # Generate the sounds bundled as Python synthesis code in the upstream repo.
    run('python3', str(HYPR / 'scripts/theme/gen-notify-sounds.py'))
    run('python3', str(ROOT / 'timer-sounds.py'))
    if args.activate:
        # Main Hyprland modules are versioned alongside the shell.
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
