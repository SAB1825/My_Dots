pragma Singleton
import Quickshell
import Quickshell.Services.Mpris
Singleton {
    readonly property var list: Mpris.players.values
    readonly property bool has: list.length > 0
}
