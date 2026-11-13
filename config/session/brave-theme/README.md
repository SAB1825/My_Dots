# Brave wallpaper theme

This theme uses the same Matugen surface color for the frame, toolbar and
new-tab background, with contrasting text and a slightly lighter address field.
It does not replace the built-in new-tab page or its widgets.

## One-time setup

Link this directory to `~/.config/session/brave-theme`, then change wallpaper
with Matugen to generate the palette and theme. The repository Matugen config
already includes the Brave template.

Close Brave completely, then sync its separate new-tab background preference:

```sh
python3 ~/.config/session/brave-theme/generate.py --sync-new-tab
```

Reopen Brave, visit `brave://extensions`, enable Developer mode, choose Load
unpacked, and select `~/.config/session/brave-theme/theme`.
This switches Brave from the GTK theme to the Matugen Wallpaper theme.

## After changing wallpaper

Matugen regenerates `palette.json` and `theme/manifest.json` automatically when
the directory is linked. Brave does not automatically reapply changed files.

1. Close Brave completely and run the `generate.py --sync-new-tab` command above.
2. Reopen Brave and reload the Matugen Wallpaper theme in `brave://extensions`.
   If Brave does not show a reload control for the theme, use Load unpacked again
   and select the same theme folder.

The sync helper updates only the Default profile's new-tab background. It refuses
to edit Preferences while a `brave` process is running. The first sync backs up
Preferences to `Preferences.before-matugen-theme` in the same profile directory.
Do not restore this entire backup after subsequent browsing; it contains other
profile preferences as well.

## Undo

Select GTK again under Brave Settings → Appearance. Remove `[templates.brave]`
from the Matugen config to stop generating the theme. Choose your previous
new-tab background in Brave's new-tab customization panel.

Theme format reference: https://developer.chrome.com/docs/extensions/develop/ui/themes
