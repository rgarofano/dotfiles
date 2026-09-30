import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

Text {
    property var panel

    text: "󰂯"
    color: panel.isOpen ? Theme.blue : Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        onClicked: parent.panel.toggle()
    }
}
