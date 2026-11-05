import QtQuick

Rectangle {
    id: root

    property string text
    property bool selected: false

    signal clicked
    signal scrolled(real delta)

    implicitWidth: label.implicitWidth + 24
    implicitHeight: 30
    radius: 9
    color: selected ? Theme.accent : mouse.containsMouse ? Theme.hover : "transparent"

    Text {
        id: label

        anchors.centerIn: parent
        text: root.text
        color: root.selected ? Theme.accentText : Theme.text
        font.family: Theme.font
        font.pixelSize: 12
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onWheel: event => {
            return root.scrolled(event.angleDelta.y);
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 130
        }
    }
}
