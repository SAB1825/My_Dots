pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "ricelin/Singletons" as Ricelin
import "ricelin" as RicelinViews

PanelWindow {
    id: barWindow
    required property ShellState controller
    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
    required property var modelData
    readonly property var monitor: Hyprland.monitorFor(modelData)
    readonly property bool ricelinPanel: controller.panel === "sound" || controller.panel === "session"
    readonly property bool opened: barWindow.controller.panel !== "" && barWindow.controller.panelScreen === modelData.name
    readonly property bool expanded: hover.hovered || linger.running
    readonly property real availableWidth: Math.max(1, width - 24)
    readonly property var panelSizes: ({
            wallpapers: Qt.size(660, 290),
            themes: Qt.size(660, 290),
            launcher: Qt.size(400, 360),
            wifi: Qt.size(360, 360),
            bluetooth: Qt.size(360, 360),
            calendar: Qt.size(400, 420),
            session: Qt.size(panelContent.preferredWidth, panelContent.preferredHeight),
            sound: Qt.size(400, panelContent.preferredHeight)
        })
    readonly property size pageSize: panelSizes[controller.panel] || Qt.size(400, 240)
    screen: modelData
    visible: barWindow.controller.barVisible || opened
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: modelData.height
    exclusiveZone: barWindow.controller.barVisible ? 48 : 0
    color: "transparent"
    WlrLayershell.layer: opened ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.namespace: "minimal-island"
    WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    mask: Region {
        x: barWindow.opened ? 0 : island.x
        y: barWindow.opened ? 0 : island.y
        width: barWindow.opened ? barWindow.width : island.width
        height: barWindow.opened ? barWindow.height : island.height
    }
    MouseArea {
        anchors.fill: parent
        enabled: barWindow.opened
        onClicked: barWindow.controller.panel = ""
    }
    Rectangle {
        id: island
        anchors.top: parent.top
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(barWindow.availableWidth, barWindow.opened ? barWindow.pageSize.width : barContents.implicitWidth + 24)
        height: barWindow.opened ? Math.min(barWindow.height - 32, barWindow.pageSize.height) : barWindow.expanded ? 44 : 38
        radius: barWindow.opened ? 24 : height / 2
        border.width: 1
        border.color: barWindow.ricelinPanel && barWindow.opened ? Ricelin.Theme.border : Theme.hover
        gradient: Gradient {
            GradientStop {
                position: 0
                color: barWindow.ricelinPanel && barWindow.opened ? Ricelin.Theme.cardTop : Theme.surface
            }
            GradientStop {
                position: 1
                color: barWindow.ricelinPanel && barWindow.opened ? Ricelin.Theme.cardBot : Theme.background
            }
        }
        clip: true
        Behavior on width {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        MouseArea {
            anchors.fill: parent
        }
        HoverHandler {
            id: hover
            onHoveredChanged: {
                if (hovered)
                    linger.stop();
                else
                    linger.restart();
            }
        }
        Timer {
            id: linger
            interval: 350
        }
        RowLayout {
            id: barContents
            anchors.centerIn: parent
            spacing: 12
            visible: !barWindow.opened
            // Keep the launcher and workspace strip in the same order in both faces.
            IslandButton {
                icon: "󰣇"
                hint: "Applications"
                active: true
                onClicked: barWindow.controller.toggle("launcher", barWindow.modelData.name)
            }
            Row {
                spacing: 4
                Layout.alignment: Qt.AlignVCenter
                Repeater {
                    model: {
                        const ids = new Set([1, 2, 3, 4, 5]);
                        for (const ws of Hyprland.workspaces.values)
                            if (ws.id > 0 && ws.monitor?.name === barWindow.modelData.name)
                                ids.add(ws.id);
                        return Array.from(ids).sort((a, b) => a - b);
                    }
                    Item {
                        id: workspace
                        required property int modelData
                        readonly property bool active: barWindow.monitor?.activeWorkspace?.id === modelData
                        width: active ? 17 : 9
                        height: 28
                        Behavior on width {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            width: workspace.active ? 17 : 5
                            height: 5
                            radius: 3
                            color: workspace.active ? Theme.accent : Theme.text
                            opacity: workspace.active ? 1 : dotMouse.containsMouse ? 0.75 : 0.3
                            Behavior on width {
                                NumberAnimation {
                                    duration: 180
                                }
                            }
                        }
                        MouseArea {
                            id: dotMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Hyprland.dispatch('hl.dsp.focus({workspace=' + workspace.modelData + '})')
                        }
                    }
                }
            }
            Rectangle {
                width: 1
                height: 12
                color: Theme.text
                opacity: 0.13
            }
            Item {
                visible: barWindow.controller.playing && barWindow.controller.status.cava
                Layout.preferredWidth: 46
                Layout.preferredHeight: 24
                Row {
                    anchors.centerIn: parent
                    spacing: 2
                    Repeater {
                        model: 12
                        Rectangle {
                            required property int index
                            width: 2
                            height: Math.max(2, (barWindow.controller.levels[index] || 0) * 0.18)
                            radius: 1
                            anchors.verticalCenter: parent.verticalCenter
                            color: barWindow.controller.player?.isPlaying ? Theme.accent : Theme.muted
                            Behavior on height {
                                NumberAnimation {
                                    duration: 65
                                }
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (barWindow.controller.player?.canTogglePlaying)
                        barWindow.controller.player.togglePlaying()
                }
                ToolTip.visible: musicHover.hovered
                ToolTip.text: barWindow.controller.player ? barWindow.controller.player.trackTitle || barWindow.controller.player.identity : "No music playing"
                HoverHandler {
                    id: musicHover
                }
            }
            Text {
                text: Qt.formatDateTime(clock.date, barWindow.expanded ? "ddd, dd MMM  ·  hh:mm" : "hh:mm")
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 12
                font.weight: Font.Medium
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barWindow.controller.toggle("calendar", barWindow.modelData.name)
                }
            }
            Text {
                visible: !!barWindow.controller.status.battery?.available
                text: (barWindow.controller.status.battery?.state === "Charging" ? "󰂄 " : "󰁹 ") + (barWindow.controller.status.battery?.percent || 0) + "%"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 11
                ToolTip.visible: batteryHover.hovered
                ToolTip.text: barWindow.controller.status.battery?.state || ""
                HoverHandler {
                    id: batteryHover
                }
            }
            RowLayout {
                visible: barWindow.expanded
                spacing: 2
                IslandButton {
                    icon: barWindow.controller.status.wifi ? "󰤨" : "󰤭"
                    hint: barWindow.controller.status.wifiError || barWindow.controller.status.network
                    onClicked: barWindow.controller.toggle("wifi", barWindow.modelData.name)
                }
                IslandButton {
                    icon: "󰂯"
                    active: barWindow.controller.status.bluetooth
                    hint: barWindow.controller.status.bluetoothError || "Bluetooth"
                    onClicked: barWindow.controller.toggle("bluetooth", barWindow.modelData.name)
                }
                RicelinViews.BarButton {
                    glyph: barWindow.controller.sink?.audio?.muted ? "speaker-off" : "speaker"
                    hint: barWindow.controller.audioAvailable ? "Volume " + Math.round(barWindow.controller.sink.audio.volume * 100) + "% · scroll to adjust" : "No audio output"
                    onClicked: barWindow.controller.toggle("sound", barWindow.modelData.name)
                    onScrolled: delta => barWindow.controller.setVolume((barWindow.controller.sink?.audio?.volume || 0) + (delta > 0 ? 0.05 : -0.05))
                }
                IslandButton {
                    icon: "󰸉"
                    hint: "Wallpapers"
                    onClicked: barWindow.controller.toggle("wallpapers", barWindow.modelData.name)
                }
                IslandButton {
                    icon: "󰏘"
                    hint: "Themes · Super+C"
                    onClicked: barWindow.controller.toggle("themes", barWindow.modelData.name)
                }
                RicelinViews.BarButton {
                    glyph: "shutdown"
                    hint: "Session"
                    onClicked: barWindow.controller.toggle("session", barWindow.modelData.name)
                }
            }
            Rectangle {
                width: 6
                height: 6
                radius: 3
                color: Theme.glow
                visible: !barWindow.expanded
            }
        }
        PanelContent {
            id: panelContent
            anchors.fill: parent
            anchors.margins: barWindow.ricelinPanel ? 0 : 14
            controller: barWindow.controller
            opened: barWindow.opened
        }
    }
    Shortcut {
        sequence: "Escape"
        enabled: barWindow.opened
        onActivated: if (!panelContent.back())
            barWindow.controller.panel = ""
    }
}
