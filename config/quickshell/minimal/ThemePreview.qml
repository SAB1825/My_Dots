import QtQuick

Rectangle {
    id: preview

    required property var palette

    radius: 7
    color: palette.background
    border.color: palette.hover
    border.width: 1

    Rectangle {
        anchors.top: parent.top
        anchors.topMargin: 9
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.72
        height: 14
        radius: 7
        color: preview.palette.surface

        Row {
            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: [preview.palette.accent, preview.palette.muted, preview.palette.glow]

                Rectangle {
                    required property string modelData

                    width: 14
                    height: 3
                    radius: 2
                    color: modelData
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 33
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        radius: 5
        color: preview.palette.surface
        border.width: 1
        border.color: preview.palette.hover

        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 5

            Text {
                text: "❯ kitty"
                color: preview.palette.accent
                font.family: Theme.font
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width * 0.75
                height: 3
                radius: 1
                color: preview.palette.text
            }

            Row {
                spacing: 4

                Repeater {
                    model: [preview.palette.red, preview.palette.green, preview.palette.yellow, preview.palette.blue, preview.palette.magenta, preview.palette.cyan]

                    Rectangle {
                        required property string modelData

                        width: 12
                        height: 7
                        radius: 2
                        color: modelData
                    }
                }
            }
        }
    }
}
