import QtQuick
import Quickshell

import ".."

Text {
    id: root

    required property var panel

    text: "󰂚"
    color: panel.visible ? Theme.blue : Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        onClicked: root.panel.visible = !root.panel.visible
   }

   Behavior on color {
       ColorAnimation { duration: 150 }
   }
}
