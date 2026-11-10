import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import "root:/design"
import "root:/services"

Scope {
    id: root

    property bool armed: false
    property bool showing: false
    property bool peek: false

    function up() {
        if (root.showing)
            return;
        root.showing = true;
        reveal.restart();
    }

    IpcHandler {
        target: "curtain"

        function up(): string {
            root.up();
            return "ok";
        }

        function peek(on: bool): string {
            root.peek = on;
            return on ? "shown" : "hidden";
        }
    }

    property real k: 0

    SequentialAnimation {
        id: reveal
        ScriptAction { script: root.k = 0 }
        NumberAnimation {
            target: root; property: "k"
            from: 0; to: 1; duration: 360
            easing.type: Easing.InOutSine
        }
        ScriptAction {
            script: {
                Emergence.launch();
                root.showing = false;
                root.k = 0;
            }
        }
    }

    PanelWindow {
        id: win

        WlrLayershell.namespace: "qs-curtain"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        screen: Focus.screen
        visible: root.armed || root.showing || root.peek

        anchors { top: true; bottom: true; left: true; right: true }
        exclusiveZone: -1
        color: "transparent"
        mask: Region {}

        LockFace {
            anchors.fill: parent
            live: root.armed || root.showing || root.peek
            opacity: 1 - root.k
        }
    }
}
