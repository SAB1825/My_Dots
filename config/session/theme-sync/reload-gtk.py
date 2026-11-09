#!/usr/bin/env python3
"""Alternate equivalent theme names so running GTK clients reload their CSS."""
from pathlib import Path
import configparser
import subprocess

config = Path.home() / '.config'
settings = config / 'gtk-3.0/settings.ini'
parser = configparser.ConfigParser()
parser.read(settings)
current = parser.get('Settings', 'gtk-theme-name', fallback='Quickshell-B')
name = 'Quickshell-A' if current == 'Quickshell-B' else 'Quickshell-B'
for version in ('3', '4'):
    path = config / f'gtk-{version}.0/settings.ini'
    ini = configparser.ConfigParser()
    ini.read(path)
    if not ini.has_section('Settings'):
        ini.add_section('Settings')
    ini.set('Settings', 'gtk-theme-name', name)
    ini.set('Settings', 'gtk-application-prefer-dark-theme', '1')
    with path.open('w') as stream:
        ini.write(stream)
subprocess.run(['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme', name], check=True)
