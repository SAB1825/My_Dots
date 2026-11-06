pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    // Keep shell surfaces monochrome, independent of application/wallpaper themes.
    readonly property color background: "#000000"
    readonly property color surface: "#111111"
    readonly property color hover: "#2a2a2a"
    readonly property color text: "#ffffff"
    readonly property color muted: "#aaaaaa"
    readonly property color accent: "#ffffff"
    readonly property color glow: "#dddddd"
    readonly property color accentText: "#000000"
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
