pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "panels" as Panels

ColumnLayout {
    id: panelContent
    required property ShellState controller
    required property bool opened
    readonly property bool expandedPanel: controller.panel === "sound" || controller.panel === "session"
    readonly property real preferredWidth: controller.panel === "session" && pageLoader.item ? pageLoader.item.implicitWidth : 400
    readonly property real preferredHeight: pageLoader.item ? pageLoader.item.implicitHeight + (controller.panel === "session" ? 0 : 35) : 120
    function back() {
        return pageLoader.item && typeof pageLoader.item.back === "function" && pageLoader.item.back();
    }
    spacing: expandedPanel ? 0 : 8
    visible: panelContent.opened
    opacity: panelContent.opened ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 220
        }
    }
    RowLayout {
        visible: !panelContent.expandedPanel
        Layout.fillWidth: true
        Rectangle {
            width: 5
            height: 5
            radius: 3
            color: Theme.accent
        }
        Text {
            text: ({
                    launcher: "Applications",
                    wallpapers: "Wallpapers",
                    themes: "Themes · " + Theme.name,
                    wifi: "Wi-Fi",
                    bluetooth: "Bluetooth",
                    sound: "Sound",
                    session: "Session",
                    calendar: "Today"
                })[panelContent.controller.panel] || ""
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.Medium
            Layout.fillWidth: true
        }
        IslandButton {
            icon: "󰅖"
            hint: "Close · Escape"
            onClicked: panelContent.controller.panel = ""
        }
    }
    Loader {
        id: pageLoader
        focus: true
        Keys.onPressed: event => {
            if (item && typeof item.handleKey === "function")
                event.accepted = item.handleKey(event);
        }
        Keys.onReleased: event => {
            if (item && typeof item.handleRelease === "function")
                event.accepted = item.handleRelease(event);
        }
        Layout.fillWidth: true
        Layout.fillHeight: true
        active: panelContent.opened
        sourceComponent: ({
                launcher: launcher,
                wallpapers: wallpaperPicker,
                themes: themePicker,
                calendar: calendarPage,
                wifi: connectionsPage,
                bluetooth: connectionsPage,
                sound: soundPage,
                session: sessionPage
            })[panelContent.controller.panel] || null
        onLoaded: if (item) {
            if (typeof item.focusField === "function")
                item.focusField();
            else
                item.forceActiveFocus();
        }
    }
    Text {
        text: panelContent.controller.message
        visible: text !== "" && !panelContent.expandedPanel
        color: Theme.accent
        font.family: Theme.font
        font.pixelSize: 11
        wrapMode: Text.Wrap
        Layout.fillWidth: true
        maximumLineCount: 4
        elide: Text.ElideRight
    }
    Component {
        id: launcher
        Launcher {
            onDismissed: panelContent.controller.panel = ""
        }
    }
    Component {
        id: calendarPage
        CalendarView {}
    }
    Component {
        id: connectionsPage
        ConnectionsView {
            wifi: panelContent.controller.panel === "wifi"
            items: wifi ? panelContent.controller.networks : panelContent.controller.devices
            busy: panelContent.controller.connectionBusy
            powered: wifi ? !!panelContent.controller.status.wifi : !!panelContent.controller.status.bluetooth
            available: wifi ? !!panelContent.controller.status.wifiAvailable : !!panelContent.controller.status.bluetoothAvailable
            onRefreshRequested: scan => panelContent.controller.loadConnections(scan)
            onPowerRequested: panelContent.controller.deviceAction(wifi ? "wifi" : "bluetooth", powered ? "off" : "on")
            onActionRequested: data => panelContent.controller.connectionRequest(data)
        }
    }
    Component {
        id: wallpaperPicker
        WallpaperStrip {
            wallpapers: panelContent.controller.wallpapers
            busy: panelContent.controller.wallpaperBusy
            onApplyRequested: path => panelContent.controller.applyWallpaper(path)
        }
    }
    Component {
        id: themePicker
        ColumnLayout {
            function focusField() {
                themeStrip.focusField();
            }
            spacing: 4
            WallpaperStrip {
                id: themeStrip
                Layout.fillWidth: true
                Layout.fillHeight: true
                wallpapers: panelContent.controller.themeOptions
                busy: panelContent.controller.themeBusy
                searchHint: "Search themes…"
                emptyHint: "Loading themes…"
                activePath: Theme.themeId
                onApplyRequested: name => panelContent.controller.applyTheme(name)
            }
            Text {
                text: "Brave: select Use GTK in Appearance ↗"
                font.family: Theme.font
                font.pixelSize: 9
                color: Theme.muted
                Layout.alignment: Qt.AlignHCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: panelContent.controller.execute(["brave", "brave://settings/appearance"])
                }
            }
        }
    }
    Component {
        id: sessionPage
        Panels.Power {
            open: panelContent.opened
            onRequestClose: panelContent.controller.panel = ""
        }
    }
    Component {
        id: soundPage
        Panels.SoundSurface {
            open: panelContent.opened
            onRequestClose: panelContent.controller.panel = ""
            onRequestSurface: name => {
                if (name === "media")
                    panelContent.controller.execute(["playerctl", "play-pause"]);
            }
        }
    }
}
