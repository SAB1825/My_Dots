pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    readonly property color background: store.palette.background || "#000000"
    readonly property color surface: store.palette.surface || "#111111"
    readonly property color hover: store.palette.hover || "#2a2a2a"
    readonly property color text: store.palette.text || "#ffffff"
    readonly property color muted: store.palette.muted || "#aaaaaa"
    readonly property color accent: store.palette.accent || "#ffffff"
    readonly property color glow: store.palette.glow || "#dddddd"
    readonly property color accentText: store.palette.onAccent || "#000000"
    readonly property string name: store.name
    readonly property string themeId: store.themeId
    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    property FileView themeFile

    themeFile: FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/minimal/theme.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()

        JsonAdapter {
            id: store

            property string themeId: "monochrome"
            property string name: "Monochrome"
            property var palette: ({})
        }
    }
}
