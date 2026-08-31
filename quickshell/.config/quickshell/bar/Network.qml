import Quickshell
import QtQuick

import ".."
import "../services"

Text {
    property var panel

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge
    text: {
        if (!Internet.intf) {
            return "󰯡"
        }
        if (Internet.ssid) {
            return ""
        }
        return "󰈀"
    }
    color: panel.visible ? Theme.blue : Theme.foreground

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        onClicked: parent.panel.visible = !parent.panel.visible
    }
}
