import Quickshell
import QtQuick

import ".."

Text {
    property var panel

    font.family: Theme.fontFamily
    font.pixelSize: 18
    text: ""
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
