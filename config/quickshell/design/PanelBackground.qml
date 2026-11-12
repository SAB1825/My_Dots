import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "root:/design"

ClippingRectangle {
    id: panel

    default property alias content: face.data
    property color glow: Colors.accent
    color: "black"
    radius: Shape.modal

    RectangularShadow {
        x: panel.width * 0.20 - 40
        y: panel.height * 0.36 - 60
        width: 240
        height: 180
        radius: 90
        blur: 100
        color: Colors.alpha(panel.glow, 0.30)
    }

    RectangularShadow {
        x: panel.width * 0.76 - 40
        y: panel.height * 0.58 - 60
        width: 260
        height: 190
        radius: 95
        blur: 110
        color: Colors.alpha(Qt.lighter(panel.glow, 1.3), 0.14)
    }

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 1
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(0, parent.width - 90)
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.16) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Item {
        id: face
        anchors.fill: parent
    }
}
