"""Shared theme palettes and transactional application exports. No third-party Python deps."""
from contextlib import contextmanager
from pathlib import Path
import configparser
import fcntl
import json
import os
import re
import shutil
import signal
import subprocess
import tempfile
import time
import uuid

HOME = Path.home()
CONFIG = Path(os.environ.get('XDG_CONFIG_HOME', HOME / '.config'))
DATA = Path(os.environ.get('XDG_DATA_HOME', HOME / '.local/share'))
STATE = Path(os.environ.get('XDG_STATE_HOME', HOME / '.local/state')) / 'quickshell/minimal'
ROOT = CONFIG / 'quickshell/minimal'
GENERATED = ROOT / 'generated'
ROLES = ('background', 'surface', 'hover', 'text', 'muted', 'accent', 'glow',
         'red', 'green', 'yellow', 'blue', 'magenta', 'cyan', 'onAccent')
NAMES = {'catppuccin': 'Catppuccin Mocha', 'monochrome': 'Monochrome',
         'gruvbox': 'Gruvbox Dark', 'nord': 'Nord', 'dynamic': 'Dynamic'}
PRESETS = {
    'monochrome': ['#000000', '#111111', '#2a2a2a', '#ffffff', '#aaaaaa', '#ffffff', '#dddddd',
                   '#cccccc', '#dddddd', '#eeeeee', '#bbbbbb', '#dddddd', '#cccccc', '#000000'],
    'catppuccin': ['#1e1e2e', '#313244', '#45475a', '#cdd6f4', '#a6adc8', '#cba6f7', '#f5c2e7',
                   '#f38ba8', '#a6e3a1', '#f9e2af', '#89b4fa', '#cba6f7', '#94e2d5', '#1e1e2e'],
    'gruvbox': ['#282828', '#3c3836', '#504945', '#ebdbb2', '#a89984', '#fabd2f', '#fe8019',
                '#fb4934', '#b8bb26', '#fabd2f', '#83a598', '#d3869b', '#8ec07c', '#282828'],
    'nord': ['#2e3440', '#3b4252', '#434c5e', '#eceff4', '#a5b0c2', '#88c0d0', '#81a1c1',
             '#bf616a', '#a3be8c', '#ebcb8b', '#81a1c1', '#b48ead', '#8fbcbb', '#2e3440'],
}


def run(args, timeout=8):
    try:
        r = subprocess.run(args, capture_output=True, text=True, timeout=timeout,
                           env={**os.environ, 'LC_ALL': 'C'})
        return r.returncode == 0, r.stdout.strip(), r.stderr.strip()
    except (OSError, subprocess.TimeoutExpired) as e:
        return False, '', str(e)


def atomic(path, text):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = None
    try:
        with tempfile.NamedTemporaryFile('w', dir=path.parent, delete=False) as f:
            tmp = Path(f.name)
            f.write(text)
        os.replace(tmp, path)
    finally:
        if tmp and tmp.exists():
            tmp.unlink()


def read_json(path, default):
    try:
        return json.loads(Path(path).read_text())
    except (OSError, ValueError):
        return default


@contextmanager
def locked():
    STATE.mkdir(parents=True, exist_ok=True)
    with (STATE / 'theme.lock').open('a') as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        yield


def validate(palette):
    if any(not re.fullmatch(r'#[0-9a-fA-F]{6}', palette.get(role, '')) for role in ROLES):
        raise ValueError('Invalid theme palette')
    return palette


def preset(name):
    return dict(zip(ROLES, PRESETS[name]))


def state():
    result = read_json(STATE / 'theme.json', {})
    if result.get('id') not in NAMES:
        return {'id': 'monochrome', 'name': 'Monochrome', 'palette': preset('monochrome'), 'wallpaper': ''}
    try:
        validate(result['palette'])
        return result
    except (ValueError, KeyError):
        return {'id': 'monochrome', 'name': 'Monochrome', 'palette': preset('monochrome'), 'wallpaper': ''}


def current_wallpaper():
    ok, output, _ = run(['awww', 'query'], 3)
    if ok:
        for line in output.splitlines():
            if 'image: ' in line:
                p = Path(line.split('image: ', 1)[1].strip()).expanduser()
                if p.is_file():
                    return str(p.resolve())
    cached = read_json(STATE / 'wallpaper.json', {}).get('path', '')
    if cached and Path(cached).is_file():
        return str(Path(cached).resolve())
    cache = Path(os.environ.get('XDG_CACHE_HOME', HOME / '.cache')) / 'awww'
    # awww stores output settings as NUL-separated fields ending in the image path.
    for file in sorted(cache.glob('*/*')):
        try:
            if not file.is_file() or file.stat().st_size > 65536:
                continue
            for field in reversed(file.read_bytes().split(b'\0')):
                p = Path(field.decode('utf-8')).expanduser()
                if p.is_absolute() and p.is_file():
                    return str(p.resolve())
        except (OSError, UnicodeError, ValueError):
            continue
    return ''


def dynamic_palette(image):
    if not image or not Path(image).is_file():
        raise ValueError('Select a wallpaper before enabling Dynamic')
    ok, output, error = run(['matugen', 'image', image, '--dry-run', '--source-color-index', '0',
                             '--mode', 'dark', '--json', 'hex', '--old-json-output'], 40)
    if not ok:
        raise ValueError(error or output or 'Matugen could not generate colors')
    data = json.loads(output)
    colors = data['colors']
    def color(role):
        return colors[role]['dark']
    p = dict(zip(ROLES[:7], [color(r) for r in ('surface', 'surface_container', 'surface_container_highest',
                       'on_surface', 'on_surface_variant', 'primary', 'tertiary')]))
    # Material roles for UI; wallpaper-derived tonal palettes for readable ANSI/syntax colors.
    tones = data['palettes']
    p.update(red=color('error'), green=tones['secondary']['80'], yellow=tones['tertiary']['90'],
             blue=tones['primary']['80'], magenta=tones['tertiary']['80'], cyan=color('secondary'),
             onAccent=color('on_primary'))
    return validate(p)


def kitty(p):
    settings = {'background': p['background'], 'foreground': p['text'], 'cursor': p['accent'],
                'cursor_text_color': p['onAccent'], 'selection_background': p['accent'],
                'selection_foreground': p['onAccent'], 'url_color': p['blue'],
                'active_border_color': p['accent'], 'inactive_border_color': p['hover'],
                'active_tab_background': p['accent'], 'active_tab_foreground': p['onAccent'],
                'inactive_tab_background': p['surface'], 'inactive_tab_foreground': p['muted'],
                'tab_bar_background': p['background']}
    ansi = [p['surface'], p['red'], p['green'], p['yellow'], p['blue'], p['magenta'], p['cyan'], p['text'],
            p['muted'], p['red'], p['green'], p['yellow'], p['blue'], p['magenta'], p['cyan'], p['text']]
    settings.update({f'color{i}': c for i, c in enumerate(ansi)})
    return '# Generated by Quickshell themes.\n' + ''.join(f'{k} {v}\n' for k, v in settings.items())


def gtk(p):
    aliases = {'theme_bg_color': 'background', 'theme_fg_color': 'text', 'theme_base_color': 'surface',
               'theme_text_color': 'text', 'theme_selected_bg_color': 'accent', 'theme_selected_fg_color': 'onAccent',
               'theme_unfocused_bg_color': 'background', 'theme_unfocused_fg_color': 'muted',
               'theme_unfocused_base_color': 'surface', 'theme_unfocused_text_color': 'muted',
               'borders': 'hover', 'unfocused_borders': 'hover', 'warning_color': 'yellow', 'error_color': 'red',
               'success_color': 'green', 'accent_color': 'accent', 'accent_bg_color': 'accent',
               'accent_fg_color': 'onAccent', 'window_bg_color': 'background', 'window_fg_color': 'text',
               'view_bg_color': 'surface', 'view_fg_color': 'text', 'headerbar_bg_color': 'surface',
               'headerbar_fg_color': 'text', 'popover_bg_color': 'surface', 'popover_fg_color': 'text',
               'dialog_bg_color': 'surface', 'dialog_fg_color': 'text', 'card_bg_color': 'surface',
               'card_fg_color': 'text', 'sidebar_bg_color': 'surface', 'sidebar_fg_color': 'text'}
    css = '/* Generated by Quickshell themes. */\n'
    css += ''.join(f'@define-color {k} {p[v]};\n' for k, v in aliases.items())
    css += '''
window, dialog, .background { background-color: @theme_bg_color; color: @theme_fg_color; }
headerbar, .titlebar, toolbar, menubar, .sidebar { background-image: none; background-color: @headerbar_bg_color; color: @headerbar_fg_color; }
entry, textview, textview text, treeview, list, popover, menu { background-color: @theme_base_color; color: @theme_text_color; }
button { background-image: none; background-color: @theme_base_color; color: @theme_text_color; border-color: @borders; }
button:hover, row:hover { background-color: @borders; }
button:checked, button.suggested-action, row:selected, selection, *:selected { background-color: @theme_selected_bg_color; color: @theme_selected_fg_color; }
scale highlight, progressbar progress { background-color: @accent_bg_color; }
*:disabled { color: @theme_unfocused_fg_color; }
'''
    return css


def hyprland(p):
    accent, dim, shadow = p['accent'][1:], p['hover'][1:], p['background'][1:]
    return ('-- Generated by Quickshell themes.\n'
            'hl.config({general={col={active_border="rgba(' + accent + 'ff)",inactive_border="rgba(' + dim + 'aa)"}},'
            'decoration={shadow={color=0xff' + shadow + '}}})\n')


def nvim(p):
    # This file is generated only; no init.lua, plugins or runtimepath is modified.
    groups = {
        'Normal': ('text', 'background'), 'NormalFloat': ('text', 'surface'),
        'FloatBorder': ('accent', 'surface'), 'Comment': ('muted', None),
        'String': ('green', None), 'Character': ('green', None), 'Number': ('yellow', None),
        'Boolean': ('yellow', None), 'Constant': ('yellow', None), 'Identifier': ('text', None),
        'Function': ('blue', None), 'Statement': ('magenta', None), 'Keyword': ('magenta', None),
        'Operator': ('cyan', None), 'PreProc': ('glow', None), 'Type': ('yellow', None),
        'Special': ('cyan', None), 'Delimiter': ('muted', None), 'Error': ('red', None),
        'Todo': ('onAccent', 'accent'), 'Visual': ('text', 'hover'), 'Search': ('onAccent', 'accent'),
        'IncSearch': ('background', 'yellow'), 'CurSearch': ('background', 'yellow'),
        'CursorLine': (None, 'surface'), 'CursorLineNr': ('accent', None), 'LineNr': ('muted', None),
        'SignColumn': ('muted', 'background'), 'EndOfBuffer': ('background', None),
        'StatusLine': ('text', 'surface'), 'StatusLineNC': ('muted', 'surface'),
        'Pmenu': ('text', 'surface'), 'PmenuSel': ('onAccent', 'accent'),
        'WinSeparator': ('hover', None), 'MatchParen': ('accent', 'hover'),
        'DiagnosticError': ('red', None), 'DiagnosticWarn': ('yellow', None),
        'DiagnosticInfo': ('blue', None), 'DiagnosticHint': ('cyan', None),
        'DiffAdd': ('green', 'surface'), 'DiffDelete': ('red', 'surface'), 'DiffChange': ('yellow', 'surface'),
        '@variable': ('text', None), '@function': ('blue', None), '@keyword': ('magenta', None),
        '@string': ('green', None), '@type': ('yellow', None), '@comment': ('muted', None),
    }
    text = ('-- Generated palette; load later with :colorscheme quickshell after adding this runtime.\n'
            'vim.cmd("highlight clear")\nvim.o.termguicolors = true\nvim.o.background = "dark"\n'
            'vim.g.colors_name = "quickshell"\nlocal p = {\n')
    text += ''.join(f'  {k} = "{v}",\n' for k, v in p.items()) + '}\n'
    for name, (fg, bg) in groups.items():
        opts = []
        if fg: opts.append('fg = p.' + fg)
        if bg: opts.append('bg = p.' + bg)
        if name in ('Comment', '@comment'): opts.append('italic = true')
        text += f'vim.api.nvim_set_hl(0, "{name}", {{' + ', '.join(opts) + '})\n'
    text += ''.join(f'vim.g.terminal_color_{i} = "{c}"\n' for i, c in enumerate([
        p['surface'], p['red'], p['green'], p['yellow'], p['blue'], p['magenta'], p['cyan'], p['text'],
        p['muted'], p['red'], p['green'], p['yellow'], p['blue'], p['magenta'], p['cyan'], p['text']]))
    return text


def exports(p):
    validate(p)
    return {'kitty.conf': kitty(p), 'gtk3.css': gtk(p), 'gtk4.css': gtk(p),
            'hyprland.lua': hyprland(p), 'nvim/colors/quickshell.lua': nvim(p),
            'palette.json': json.dumps(p, indent=2) + '\n'}


def gtk_settings(path, theme):
    config = configparser.ConfigParser(interpolation=None)
    config.optionxform = str
    if path.exists(): config.read(path)
    if not config.has_section('Settings'): config.add_section('Settings')
    config['Settings']['gtk-theme-name'] = theme
    config['Settings']['gtk-application-prefer-dark-theme'] = '1'
    import io
    out = io.StringIO(); config.write(out)
    return out.getvalue()


def reload_apps(theme):
    warnings = []
    # Signal only this user's Kitty processes, never shell children or other programs.
    for proc in Path('/proc').glob('[0-9]*'):
        try:
            if proc.stat().st_uid == os.getuid() and (proc / 'comm').read_text().strip() == 'kitty':
                os.kill(int(proc.name), signal.SIGUSR1)
        except (OSError, ValueError):
            pass
    ok, _, err = run(['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme', theme])
    if not ok or 'failed' in err.lower(): warnings.append('GTK live refresh unavailable; new apps use the saved theme')
    ok, _, err = run(['gsettings', 'set', 'org.gnome.desktop.interface', 'color-scheme', 'prefer-dark'])
    if not ok or 'failed' in err.lower(): warnings.append('Desktop dark-mode preference could not refresh')
    script = str(GENERATED / 'current/hyprland.lua')
    ok, output, _ = run(['hyprctl', 'eval', 'dofile(' + json.dumps(script) + ')'])
    if not ok or 'error' in output.lower(): warnings.append('Hyprland live refresh unavailable; colors saved for next reload')
    return warnings


def _apply(name, image='', refresh=True):
    if name not in NAMES: raise ValueError('Unknown theme')
    previous = state()
    image = image or current_wallpaper()
    palette = dynamic_palette(image) if name == 'dynamic' else preset(name)
    revision = uuid.uuid4().hex
    slot = 'B' if previous.get('gtkSlot') == 'A' else 'A'
    theme = 'Quickshell-' + slot
    new = {'id': name, 'themeId': name, 'name': NAMES[name], 'palette': palette, 'wallpaper': image,
           'gtkSlot': slot, 'revision': revision, 'updated': int(time.time())}
    # Stage every export before switching the shared directory pointer.
    generation = GENERATED / 'generations' / revision
    for filename, content in exports(palette).items(): atomic(generation / filename, content)
    modifications = {}
    for version in ('3.0', '4.0'):
        modifications[CONFIG / ('gtk-' + version) / 'settings.ini'] = gtk_settings(CONFIG / ('gtk-' + version) / 'settings.ini', theme)
    for gtk_slot in ('A', 'B'):
        directory = DATA / 'themes' / ('Quickshell-' + gtk_slot)
        modifications[directory / 'index.theme'] = '[Desktop Entry]\nType=X-GNOME-Metatheme\nName=Quickshell-' + gtk_slot + '\n'
        for version in ('3.0', '4.0'):
            base = '@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");\n' if version == '3.0' else ''
            target = (GENERATED / 'current' / ('gtk3.css' if version == '3.0' else 'gtk4.css')).as_uri()
            modifications[directory / ('gtk-' + version) / 'gtk.css'] = base + '@import url("' + target + '");\n'
    old = {path: path.read_bytes() if path.exists() else None for path in modifications}
    pointer = GENERATED / 'current'
    old_target = os.readlink(pointer) if pointer.is_symlink() else None
    temp_link = GENERATED / ('.current-' + revision)
    try:
        for path, content in modifications.items(): atomic(path, content)
        temp_link.symlink_to(Path('generations') / revision)
        os.replace(temp_link, pointer)
        atomic(STATE / 'theme.json', json.dumps(new, indent=2) + '\n')
    except Exception:
        for path, content in old.items():
            if content is None: path.unlink(missing_ok=True)
            else: atomic(path, content.decode())
        if old_target is not None:
            temp_link.unlink(missing_ok=True); temp_link.symlink_to(old_target); os.replace(temp_link, pointer)
        elif pointer.is_symlink(): pointer.unlink()
        shutil.rmtree(generation, ignore_errors=True)
        raise
    finally:
        temp_link.unlink(missing_ok=True)
    warnings = reload_apps(theme) if refresh else []
    # Keep bounded history, including the immediately preceding generation for recovery.
    history = sorted((GENERATED / 'generations').iterdir(), key=lambda p: p.stat().st_mtime, reverse=True)
    for obsolete in history[8:]: shutil.rmtree(obsolete, ignore_errors=True)
    return {'ok': True, 'error': '', 'theme': name, 'warning': '; '.join(warnings)}


def apply_theme(name, image='', refresh=True):
    try:
        with locked(): return _apply(name, image, refresh)
    except (OSError, ValueError, KeyError) as e:
        return {'ok': False, 'error': str(e)}


def apply_wallpaper(image):
    try:
        with locked():
            path = Path(image).expanduser().resolve(strict=True)
            if not path.is_file(): raise ValueError('Wallpaper must be an image file')
            ok, output, error = run(['awww', 'img', str(path)], 30)
            if not ok: return {'ok': False, 'error': error or output or 'Wallpaper could not be applied'}
            atomic(STATE / 'wallpaper.json', json.dumps({'path': str(path)}))
            if state()['id'] == 'dynamic':
                try:
                    return _apply('dynamic', str(path))
                except (OSError, ValueError, KeyError) as e:
                    return {'ok': True, 'error': '', 'warning': 'Wallpaper applied; last good theme retained: ' + str(e)}
            return {'ok': True, 'error': '', 'warning': ''}
    except (OSError, ValueError) as e:
        return {'ok': False, 'error': str(e)}


def sync():
    try:
        with locked():
            old = state()
            if old['id'] != 'dynamic': return {'ok': True, 'changed': False}
            image = current_wallpaper()
            if not image or image == old.get('wallpaper'): return {'ok': True, 'changed': False}
            return _apply('dynamic', image)
    except (OSError, ValueError, KeyError) as e:
        return {'ok': False, 'error': str(e)}


def choices():
    current = state()
    dynamic = current['palette']
    preview_error = ''
    image = current_wallpaper()
    if image:
        try:
            signature = [image, Path(image).stat().st_mtime_ns]
            cache = read_json(STATE / 'dynamic-preview.json', {})
            if cache.get('signature') == signature:
                dynamic = validate(cache['palette'])
            else:
                dynamic = dynamic_palette(image)
                atomic(STATE / 'dynamic-preview.json', json.dumps({'signature': signature, 'palette': dynamic}))
        except (OSError, ValueError, KeyError) as e:
            preview_error = str(e)
    else:
        preview_error = 'Select a wallpaper before enabling Dynamic'
    items = []
    for key in ('catppuccin', 'monochrome', 'gruvbox', 'nord', 'dynamic'):
        palette = dynamic if key == 'dynamic' else preset(key)
        items.append({'name': NAMES[key], 'path': key, 'url': '', 'palette': palette, 'active': current['id'] == key})
    return {'ok': True, 'items': items, 'selected': current['id'], 'previewWarning': preview_error}


def refresh_integrations():
    current = state()
    warnings = reload_apps('Quickshell-' + current.get('gtkSlot', 'A'))
    pending = STATE / 'needs-hypr-reload'
    if pending.exists():
        ok, output, error = run(['hyprctl', 'reload', 'config-only'])
        if ok and 'error' not in output.lower(): pending.unlink(missing_ok=True)
        else: warnings.append('Super+C binding saved; Hyprland reload is still pending')
    return {'ok': True, 'warning': '; '.join(warnings)}
