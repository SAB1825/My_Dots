import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: view

    property var wallpapers: []
    property bool busy: false
    property string searchHint: "Search wallpapers…"
    property string emptyHint: "Add images to ~/Pictures/Wallpapers"
    property string activePath: ""
    property int selectedIndex: 0
    readonly property real cardWidth: 220
    readonly property real cardHeight: 124
    property var items: wallpapers.filter(w => {
        return w.name.toLowerCase().includes(search.text.toLowerCase());
    })

    signal applyRequested(string path)

    function resetSelection() {
        const active = activePath ? items.findIndex(item => {
            return item.path === activePath;
        }) : 0;
        selectedIndex = Math.max(0, active);
        centerSelection();
    }

    function centerSelection() {
        if (items.length)
            strip.positionViewAtIndex(selectedIndex, ListView.Center);
    }

    function focusField() {
        search.forceActiveFocus();
    }

    function move(delta) {
        if (!items.length)
            return;

        selectedIndex = Math.max(0, Math.min(items.length - 1, selectedIndex + delta));
        centerSelection();
    }

    function apply() {
        if (!busy && items[selectedIndex])
            applyRequested(items[selectedIndex].path);
    }

    onItemsChanged: Qt.callLater(resetSelection)
    onActivePathChanged: Qt.callLater(resetSelection)
    spacing: 6
    focus: true
    Keys.onLeftPressed: event => {
        view.move(-1);
        event.accepted = true;
    }
    Keys.onRightPressed: event => {
        view.move(1);
        event.accepted = true;
    }

    RowLayout {
        Layout.fillWidth: true

        TextField {
            id: search

            objectName: "stripSearch"
            Layout.fillWidth: true
            placeholderText: view.searchHint
            color: Theme.text
            placeholderTextColor: Theme.muted
            font.family: Theme.font
            font.pixelSize: 12
            onTextChanged: Qt.callLater(view.resetSelection)
            Keys.priority: Keys.BeforeItem
            Keys.forwardTo: [view]
            Keys.onUpPressed: view.move(-1)
            Keys.onDownPressed: view.move(1)
            onAccepted: view.apply()
            Component.onCompleted: forceActiveFocus()

            background: Rectangle {
                color: Theme.surface
                radius: 8
            }
        }

        Text {
            text: items.length ? (view.selectedIndex + 1) + " / " + items.length : "0 / 0"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 10
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ListView {
            id: strip

            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: 10
            leftMargin: Math.max(0, (width - view.cardWidth) / 2)
            rightMargin: leftMargin
            preferredHighlightBegin: leftMargin
            preferredHighlightEnd: leftMargin + view.cardWidth
            highlightRangeMode: ListView.ApplyRange
            currentIndex: view.selectedIndex
            onMovementEnded: {
                const centered = indexAt(contentX + width / 2, height / 2);
                if (centered >= 0)
                    view.selectedIndex = centered;

                view.centerSelection();
            }
            onWidthChanged: Qt.callLater(view.centerSelection)
            highlightMoveDuration: 220
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds
            model: view.items

            delegate: Item {
                id: tile

                required property var modelData
                required property int index
                readonly property bool selected: view.selectedIndex === index

                width: view.cardWidth
                height: strip.height

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: Math.min(view.cardHeight, Math.max(1, parent.height))
                    scale: tile.selected ? 1 : 0.9
                    opacity: tile.selected ? 1 : 0.65
                    radius: 10
                    color: Theme.surface
                    border.width: tile.selected ? 2 : 1
                    border.color: tile.selected ? Theme.text : Theme.hover
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 3
                        visible: !tile.modelData.palette
                        source: tile.modelData.url
                        asynchronous: true
                        sourceSize.width: 440
                        sourceSize.height: 248
                        fillMode: Image.PreserveAspectCrop
                    }

                    Loader {
                        anchors.fill: parent
                        anchors.margins: 3
                        active: !!tile.modelData.palette

                        sourceComponent: ThemePreview {
                            palette: tile.modelData.palette
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 28
                        color: "#dd000000"

                        Text {
                            anchors.fill: parent
                            anchors.margins: 6
                            text: (tile.modelData.path === view.activePath ? "✓ " : "") + tile.modelData.name
                            elide: Text.ElideRight
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 9
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (tile.selected) {
                                view.apply();
                            } else {
                                view.selectedIndex = tile.index;
                                view.centerSelection();
                            }
                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 180
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        MouseArea {
            property real wheelSteps: 0

            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: event => {
                const delta = event.angleDelta.y || event.angleDelta.x;
                wheelSteps += delta / 120;
                const steps = Math.trunc(wheelSteps);
                if (steps) {
                    view.move(-steps);
                    wheelSteps -= steps;
                }
                event.accepted = true;
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !view.items.length
            text: search.text.length ? "No matches" : view.emptyHint
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 11
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Chip {
            objectName: "previousWallpaper"
            text: "‹"
            enabled: view.selectedIndex > 0
            opacity: enabled ? 1 : 0.4
            onClicked: view.move(-1)
        }

        Text {
            text: "Scroll / ← → Browse · Enter Apply"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 9
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Chip {
            objectName: "nextWallpaper"
            text: "›"
            enabled: view.selectedIndex < view.items.length - 1
            opacity: enabled ? 1 : 0.4
            onClicked: view.move(1)
        }
    }
}
