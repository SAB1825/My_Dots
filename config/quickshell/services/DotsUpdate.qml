pragma Singleton
import Quickshell

// Compatibility interface for shared bar components. Desktop updater is removed.
Singleton {
    readonly property bool available: false
    readonly property int commits: 0
    readonly property real bytes: 0
    readonly property int files: 0
    readonly property bool busy: false
    function refresh() {}
    function open() {}
    function size() { return "0 B"; }
}
