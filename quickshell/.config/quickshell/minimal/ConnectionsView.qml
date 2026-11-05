import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: view

    property bool wifi: true
    property var items: []
    property bool busy: false
    property bool powered: false
    property bool available: false
    property string selectedSsid: ""

    signal refreshRequested(bool scan)
    signal powerRequested
    signal actionRequested(var data)

    spacing: 6

    RowLayout {
        Layout.fillWidth: true

        Chip {
            text: view.powered ? "Turn off" : "Turn on"
            enabled: view.available && !view.busy
            opacity: enabled ? 1 : 0.4
            onClicked: view.powerRequested()
        }

        Chip {
            text: view.busy ? "Working…" : "Scan / Refresh"
            enabled: view.powered && !view.busy
            opacity: enabled ? 1 : 0.4
            onClicked: view.refreshRequested(true)
        }
    }

    Text {
        text: !view.available ? "Adapter unavailable" : !view.powered ? "Powered off" : view.wifi ? "Select a network to connect" : "Select a device"
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 11
        wrapMode: Text.Wrap
        Layout.fillWidth: true
    }

    ListView {
        id: list

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 5
        model: view.items

        Text {
            anchors.centerIn: parent
            visible: list.count === 0 && !view.busy
            text: view.powered ? "No devices found · Scan again" : ""
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 11
        }

        delegate: Rectangle {
            required property var modelData

            width: list.width
            height: 44
            radius: 8
            color: area.containsMouse ? Theme.hover : Theme.surface

            RowLayout {
                anchors.fill: parent
                anchors.margins: 7

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3

                    Text {
                        text: view.wifi ? modelData.ssid : modelData.name
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 12
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: view.wifi ? (modelData.active ? "Connected · " : "") + modelData.signal + "% · " + (modelData.security || "Open") : modelData.connected ? "Connected · Click to disconnect" : modelData.paired ? "Paired · Click to connect" : "Click to pair"
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 9
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Text {
                    text: (view.wifi ? modelData.active : modelData.connected) ? "✓" : "+"
                    color: Theme.text
                    font.family: Theme.font
                }
            }

            MouseArea {
                id: area

                anchors.fill: parent
                hoverEnabled: true
                enabled: !view.busy && view.powered
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (view.wifi) {
                        if (modelData.active) {
                            view.actionRequested({
                                "action": "wifi-disconnect"
                            });
                            return;
                        }
                        view.selectedSsid = modelData.ssid;
                        password.text = "";
                        password.forceActiveFocus();
                    } else {
                        view.actionRequested({
                            "action": modelData.connected ? "bt-disconnect" : modelData.paired ? "bt-connect" : "bt-pair",
                            "address": modelData.address
                        });
                    }
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    ColumnLayout {
        visible: view.wifi && view.selectedSsid !== ""
        Layout.fillWidth: true

        Text {
            text: "Connect to " + view.selectedSsid
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 11
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        TextField {
            id: password

            Layout.fillWidth: true
            placeholderText: "Password (blank if saved / open)"
            placeholderTextColor: Theme.muted
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 10
            echoMode: TextInput.Password
            onAccepted: connect.clicked()

            background: Rectangle {
                radius: 8
                color: Theme.hover
            }
        }

        RowLayout {
            Chip {
                id: connect

                text: "Connect"
                enabled: !view.busy
                onClicked: {
                    view.actionRequested({
                        "action": "wifi-connect",
                        "ssid": view.selectedSsid,
                        "password": password.text
                    });
                    password.text = "";
                    view.selectedSsid = "";
                }
            }

            Chip {
                text: "Cancel"
                onClicked: {
                    password.text = "";
                    view.selectedSsid = "";
                }
            }
        }
    }
}
