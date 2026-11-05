import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "lib/calc.js" as Calc
import "lib/fuzzy.js" as Fuzzy

ColumnLayout {
    id: view

    property var usage: ({})
    property var entries: DesktopEntries.applications.values.filter(e => {
        return !e.noDisplay;
    })
    property var results: Fuzzy.rank(entries, search.text, usage)
    property var calculation: Calc.evaluate(search.text)
    property bool copied: false

    signal dismissed

    function focusField() {
        search.forceActiveFocus();
    }

    function move(delta) {
        apps.currentIndex = Math.max(0, Math.min(results.length - 1, apps.currentIndex + delta));
        apps.positionViewAtIndex(apps.currentIndex, ListView.Contain);
    }

    function activate() {
        if (calculation.ok) {
            Quickshell.execDetached(["sh", "-c", 'printf %s "$1" | wl-copy', "_", calculation.display]);
            copied = true;
            return;
        }
        const app = results[apps.currentIndex];
        if (!app)
            return;

        const next = Object.assign({}, usage);
        next[app.id] = (next[app.id] || 0) + 1;
        usage = next;
        store.setText(JSON.stringify(usage));
        app.execute();
        dismissed();
    }

    Component.onCompleted: {
        try {
            usage = JSON.parse(store.text() || "{}");
        } catch (e) {
            usage = ({});
        }
        search.forceActiveFocus();
    }
    spacing: 6

    FileView {
        id: store

        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/quickshell/minimal/launcher-usage.json"
        blockLoading: true
        atomicWrites: true
        printErrors: false
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "\uf002"
            font.family: Theme.iconFont
            font.pixelSize: 20
            color: Theme.text
        }

        TextField {
            id: search

            Layout.fillWidth: true
            placeholderText: "Search apps"
            color: Theme.text
            placeholderTextColor: Theme.muted
            font.family: Theme.font
            font.pixelSize: 14
            onTextChanged: {
                apps.currentIndex = 0;
                view.copied = false;
            }
            Keys.onDownPressed: view.move(1)
            Keys.onUpPressed: view.move(-1)
            Keys.onEscapePressed: view.dismissed()
            onAccepted: view.activate()

            background: Item {}
        }

        Text {
            text: view.results.length + " / " + view.entries.length
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 11
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Theme.hover
    }

    Chip {
        visible: view.calculation.ok
        Layout.fillWidth: true
        text: "= " + view.calculation.display + (view.copied ? "   Copied" : "   ↵ Copy")
        onClicked: view.activate()
    }

    ListView {
        id: apps

        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 5
        boundsBehavior: Flickable.StopAtBounds
        model: view.results

        Text {
            anchors.centerIn: parent
            visible: apps.count === 0
            text: "No matches"
            color: Theme.muted
            font.family: Theme.font
        }

        delegate: Rectangle {
            required property var modelData
            required property int index

            width: apps.width
            height: 38
            radius: 8
            color: apps.currentIndex === index ? Theme.surface : "transparent"
            border.width: apps.currentIndex === index ? 1 : 0
            border.color: Theme.hover

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 8

                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: "󰀻"
                        color: Theme.muted
                        font.family: Theme.iconFont
                        font.pixelSize: 21
                        visible: appIcon.status !== Image.Ready
                    }

                    Image {
                        id: appIcon

                        anchors.fill: parent
                        source: modelData.icon ? Quickshell.iconPath(modelData.icon, true) : ""
                        sourceSize.width: 28
                        sourceSize.height: 28
                        asynchronous: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: modelData.name
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.weight: apps.currentIndex === index ? Font.DemiBold : Font.Normal
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: modelData.genericName || String(modelData.categories || "").split(",")[0]
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 9
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        visible: text.length > 0
                    }
                }

                Text {
                    text: "↵"
                    visible: apps.currentIndex === index
                    color: Theme.text
                    font.family: Theme.font
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: apps.currentIndex = index
                onClicked: {
                    apps.currentIndex = index;
                    view.activate();
                }
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    Text {
        text: "↑ ↓ Select   ↵ Open / Copy   Esc Close"
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 9
    }
}
