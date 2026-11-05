import QtQuick
import QtQuick.Controls

Item {
    id: button

    property string icon
    property string hint
    property bool active: false

    signal clicked
    signal scrolled(real delta)

    implicitWidth: 29
    implicitHeight: 30
    ToolTip.visible: area.containsMouse && hint !== ""
    ToolTip.delay: 600
    ToolTip.text: hint

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: area.containsMouse ? Theme.hover : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: button.icon
        font.family: Theme.iconFont
        font.pixelSize: 15
        color: button.active || area.containsMouse ? Theme.accent : Theme.text

        Behavior on color {
            ColorAnimation {
                duration: 140
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
        onWheel: event => {
            return button.scrolled(event.angleDelta.y);
        }
    }
}
