import QtQuick
import Quickshell

import ".."

Text {
    id: bell

    text: "󰂚"
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge

    MouseArea {
        anchors.fill: parent

        cursorShape: Qt.PointingHandCursor
        onClicked: () => {
            if (bell.color == Theme.foreground) {
                bell.color = Theme.blue
            } else {
                bell.color = Theme.foreground
            }
            Quickshell.execDetached(["qs", "ipc", "call", "notificationCenter", "toggle"])
        }
   }

   Behavior on color {
       ColorAnimation { duration: 150 }
   }
}
