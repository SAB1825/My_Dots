#!/usr/bin/env python3
"""Install the generated KDE scheme and merge palette roles into kdeglobals."""
import configparser
import os
from pathlib import Path
import shutil
import subprocess


def load(path):
    ini = configparser.ConfigParser(interpolation=None)
    ini.optionxform = str
    ini.read(path)
    return ini


def merge_palette(source, config):
    ini = load(config)
    for section in source.sections():
        if section.startswith(('Colors:', 'ColorEffects:')):
            if not ini.has_section(section):
                ini.add_section(section)
            for key, value in source[section].items():
                ini.set(section, key, value)
    if not ini.has_section('General'):
        ini.add_section('General')
    ini.set('General', 'ColorScheme', 'Wallpaper')
    with config.open('w') as stream:
        ini.write(stream)


def main():
    here = Path(__file__).resolve().parent
    config = Path.home() / '.config'
    source = load(here / 'Wallpaper.colors')
    dest = Path(os.environ.get('XDG_DATA_HOME', str(Path.home() / '.local/share'))) / 'color-schemes/Wallpaper.colors'
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(here / 'Wallpaper.colors', dest)
    merge_palette(source, config / 'kdeglobals')
    dolphin = config / 'dolphinrc'
    ini = load(dolphin)
    if not ini.has_section('UiSettings'):
        ini.add_section('UiSettings')
    ini.set('UiSettings', 'ColorScheme', 'Wallpaper')
    with dolphin.open('w') as stream:
        ini.write(stream)
    # Standard KDE palette-change signal; non-Plasma sessions may need a restart.
    if shutil.which('gdbus') and os.environ.get('DBUS_SESSION_BUS_ADDRESS'):
        subprocess.run(['gdbus', 'emit', '--session', '--object-path', '/KGlobalSettings', '--signal', 'org.kde.KGlobalSettings.notifyChange', '0', '0'], check=False)


if __name__ == '__main__':
    main()
