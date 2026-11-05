# Ricelin session and sound panels

Adapted from `Downloads/Ricelin-main.zip`, `configs/quickshell/pill/`.
The upstream MIT license is retained in `LICENSE`.

`Power.qml` and `SoundSurface.qml` preserve the reference layouts, vector icons,
hold confirmation, faders, tabs and menus. Colors follow the active shell palette.
`BarButton.qml` adapts its status icon styling to the existing bar.

Local integration changes:

- Shared helpers live here; theme tokens bind to the shell palette and update live.
- The session panel sizes itself to its five 42px action tiles, header and hint.
- Typography follows the shell font. Vector header icons replace the unavailable
  Japanese font so headers do not display missing-glyph boxes.
- Lock uses `loginctl lock-session`; an active session locker must handle it.
- The sound header's media button plays/pauses through `playerctl`.
- EQ and mic filter configs are in `audio/`; systemd unit names use
  `minimal-ricelin-eq` and `minimal-ricelin-mic`.
- Sound settings live in `$XDG_STATE_HOME/quickshell/minimal/ricelin/sound.json`
  (normally `~/.local/state/quickshell/minimal/ricelin/sound.json`).
- EQ and microphone noise filtering start disabled. The noise-filter switch
  requires the RNNoise LADSPA plugin. AutoEQ downloads profiles when requested.

The session panel uses click for Lock/Sleep and a 1.1-second hold for
Log out/Restart/Shut down. Arrow keys select actions; hold Enter or Space to
confirm. Sound supports Tab to switch tabs and arrows to adjust controls.
Escape backs out of sound submenus before closing the panel.
