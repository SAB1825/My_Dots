import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

SOURCE = Path(__file__).resolve().parents[1] / 'theming.py'
spec = importlib.util.spec_from_file_location('theming', SOURCE)
t = importlib.util.module_from_spec(spec); spec.loader.exec_module(t)


class Themes(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.patches = []
        for name, value in {
            'CONFIG': self.root / 'config', 'DATA': self.root / 'data',
            'STATE': self.root / 'state', 'ROOT': self.root / 'config/quickshell/minimal',
            'GENERATED': self.root / 'config/quickshell/minimal/generated',
        }.items():
            p = patch.object(t, name, value); p.start(); self.patches.append(p)
        self.image = self.root / 'wall.png'; self.image.write_text('test')
        self.wall = patch.object(t, 'current_wallpaper', return_value=str(self.image)); self.wall.start()

    def tearDown(self):
        self.wall.stop()
        for p in self.patches: p.stop()
        self.temp.cleanup()

    def test_all_presets_export_every_target(self):
        for name in t.PRESETS:
            result = t.apply_theme(name, refresh=False)
            self.assertTrue(result['ok'], result)
            state = t.state(); self.assertEqual(state['id'], name)
            current = t.GENERATED / 'current'
            self.assertTrue(current.is_symlink())
            self.assertEqual(json.loads((current / 'palette.json').read_text()), state['palette'])
            self.assertEqual(sum(line.startswith('color') for line in (current/'kitty.conf').read_text().splitlines()), 16)
            for lua in ('hyprland.lua', 'nvim/colors/quickshell.lua'):
                subprocess.run(['luac', '-p', str(current / lua)], check=True)
            self.assertFalse((t.CONFIG / 'nvim').exists())
        self.assertEqual(t.state()['gtkSlot'], 'B')

    def test_unknown_theme_preserves_current(self):
        t.apply_theme('nord', refresh=False)
        before = (t.STATE / 'theme.json').read_bytes()
        self.assertFalse(t.apply_theme('unknown', refresh=False)['ok'])
        self.assertEqual((t.STATE / 'theme.json').read_bytes(), before)

    def test_matugen_failure_preserves_generation_and_state(self):
        t.apply_theme('gruvbox', refresh=False)
        before = (t.STATE/'theme.json').read_bytes()
        target = os.readlink(t.GENERATED/'current')
        with patch.object(t, 'dynamic_palette', side_effect=ValueError('broken image')):
            self.assertFalse(t.apply_theme('dynamic', refresh=False)['ok'])
        self.assertEqual((t.STATE/'theme.json').read_bytes(), before)
        self.assertEqual(os.readlink(t.GENERATED/'current'), target)

    def test_commit_failure_rolls_back_pointer_and_gtk(self):
        t.apply_theme('nord', refresh=False)
        before = (t.STATE/'theme.json').read_bytes()
        gtk = (t.CONFIG/'gtk-3.0/settings.ini').read_bytes()
        pointer = os.readlink(t.GENERATED/'current')
        write = t.atomic
        def fail(path, content):
            if path == t.STATE/'theme.json': raise OSError('disk failure')
            return write(path, content)
        with patch.object(t, 'atomic', side_effect=fail):
            self.assertFalse(t.apply_theme('gruvbox', refresh=False)['ok'])
        self.assertEqual((t.STATE/'theme.json').read_bytes(), before)
        self.assertEqual((t.CONFIG/'gtk-3.0/settings.ini').read_bytes(), gtk)
        self.assertEqual(os.readlink(t.GENERATED/'current'), pointer)

    def test_wallpaper_with_preset_preserves_theme(self):
        t.apply_theme('catppuccin', refresh=False)
        with patch.object(t, 'run', return_value=(True, '', '')) as run, patch.object(t, 'dynamic_palette') as generate:
            self.assertTrue(t.apply_wallpaper(str(self.image))['ok'])
            generate.assert_not_called()
            self.assertEqual(run.call_args.args[0], ['awww', 'img', str(self.image)])
        self.assertEqual(t.state()['id'], 'catppuccin')

    def test_dynamic_wallpaper_regenerates(self):
        p = t.preset('nord')
        with patch.object(t, 'dynamic_palette', return_value=p), patch.object(t, 'reload_apps', return_value=[]):
            t.apply_theme('dynamic', refresh=False)
            with patch.object(t, 'run', return_value=(True, '', '')):
                self.assertTrue(t.apply_wallpaper(str(self.image))['ok'])
        self.assertEqual(t.state()['id'], 'dynamic')
        self.assertEqual(t.state()['palette'], p)

    def test_dynamic_sync_no_redundant_generation(self):
        with patch.object(t, 'dynamic_palette', return_value=t.preset('nord')):
            t.apply_theme('dynamic', refresh=False)
        with patch.object(t, 'dynamic_palette') as generate:
            self.assertFalse(t.sync()['changed'])
            generate.assert_not_called()

    def test_invalid_palette_rejected(self):
        p = t.preset('nord'); p['accent'] = 'bad'
        with self.assertRaises(ValueError): t.exports(p)

    def test_existing_gtk_settings_preserved(self):
        path=t.CONFIG/'gtk-3.0/settings.ini'; path.parent.mkdir(parents=True)
        path.write_text('[Settings]\ngtk-font-name=Example 12\ngtk-icon-theme-name=Adwaita\n')
        t.apply_theme('monochrome', refresh=False)
        self.assertIn('Example 12', path.read_text())
        self.assertIn('gtk-icon-theme-name = Adwaita', path.read_text())

    def test_history_is_bounded(self):
        for i in range(10): self.assertTrue(t.apply_theme('nord', refresh=False)['ok'])
        self.assertEqual(len(list((t.GENERATED/'generations').iterdir())), 8)
        self.assertTrue((t.GENERATED/'current/kitty.conf').is_file())


if __name__ == '__main__': unittest.main()
