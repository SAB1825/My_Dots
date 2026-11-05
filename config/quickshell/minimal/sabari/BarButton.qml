import QtQuick
import QtQuick.Controls
import "Singletons"

// Adapter for Sabari's 17px vector status icon in the existing bar layout.
Item {
    id: button
    property string glyph
    property string hint
    signal clicked
    signal scrolled(real delta)
    implicitWidth: 29
    implicitHeight: 30

    GlyphIcon {
        anchors.centerIn: parent
        width: 17
        height: 17
        name: button.glyph
        stroke: 1.7
        color: area.containsMouse ? Theme.cream : Theme.iconDim
    }
    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
        onWheel: event => button.scrolled(event.angleDelta.y)
    }
    ToolTip.visible: area.containsMouse && hint.length > 0
    ToolTip.delay: 600
    ToolTip.text: hint
}
