import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: view

    property date today: new Date()
    property date month: new Date(today.getFullYear(), today.getMonth(), 1)
    property date selected: today
    readonly property int offset: (new Date(month.getFullYear(), month.getMonth(), 1).getDay() + 6) % 7

    function shift(delta) {
        month = new Date(month.getFullYear(), month.getMonth() + delta, 1);
    }

    spacing: 10

    RowLayout {
        Layout.fillWidth: true

        Chip {
            text: "‹"
            onClicked: view.shift(-1)
        }

        Text {
            text: Qt.formatDateTime(view.month, "MMMM yyyy")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 15
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Chip {
            text: "›"
            onClicked: view.shift(1)
        }
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        columns: 7
        rowSpacing: 4
        columnSpacing: 4

        Repeater {
            model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

            Text {
                required property string modelData

                text: modelData
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 11
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Repeater {
            model: 42

            Rectangle {
                id: day

                required property int index
                readonly property date value: new Date(view.month.getFullYear(), view.month.getMonth(), index - view.offset + 1)
                readonly property bool current: value.getMonth() === view.month.getMonth()
                readonly property bool chosen: value.toDateString() === view.selected.toDateString()

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 28
                radius: 8
                color: chosen ? Theme.text : area.containsMouse ? Theme.hover : "transparent"
                border.width: value.toDateString() === view.today.toDateString() ? 1 : 0
                border.color: Theme.muted

                Text {
                    anchors.centerIn: parent
                    text: day.value.getDate()
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: day.chosen ? Theme.background : day.current ? Theme.text : Theme.muted
                    opacity: day.current ? 1 : 0.4
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: view.selected = day.value
                }
            }
        }
    }

    RowLayout {
        Text {
            text: Qt.formatDateTime(view.selected, "ddd, dd MMM yyyy")
            font.family: Theme.font
            color: Theme.muted
            font.pixelSize: 11
            Layout.fillWidth: true
        }

        Chip {
            text: "Today"
            onClicked: {
                view.today = new Date();
                view.selected = view.today;
                view.month = new Date(view.today.getFullYear(), view.today.getMonth(), 1);
            }
        }
    }
}
