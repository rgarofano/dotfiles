import QtQuick
import Quickshell

import ".."

Text {
    required property var panel

    text: "󰂚"
    color: panel.isOpen ? Theme.blue : Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        onClicked: parent.panel.toggle()
   }

   Behavior on color {
       ColorAnimation { duration: 150 }
   }
}
