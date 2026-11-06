#!/bin/sh
export PATH="$HOME/.local/bin:$PATH"
store="$HOME/.config/hypr/scripts/clipboard/cliphist-store.sh"
if ! pgrep -u "$(id -u)" -f 'wl-paste --watch .*cliphist-store.sh' >/dev/null; then
    setsid -f wl-paste --watch "$store" >/dev/null 2>&1
fi
exec qs -n -d
