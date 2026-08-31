import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

Text {
    property var panel

    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeLarge
    text: Pipewire.defaultAudioSink?.audio?.muted ? "": ""
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
