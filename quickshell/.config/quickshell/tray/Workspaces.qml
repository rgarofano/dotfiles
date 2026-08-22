import Quickshell
import Quickshell.Hyprland
import QtQuick

import ".."

Repeater {
    model: Hyprland.workspaces

    Rectangle {
        required property var modelData
        width: 30
        height: 30

        visible: modelData != null
        color: modelData.focused ? Theme.brightBlack : Theme.background

        Text {
            anchors.centerIn: parent
            text: modelData?.id
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: modelData.focused ? Theme.foreground : Theme.brightBlack
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Hyprland.dispatch('hl.dsp.focus({ workspace = "' + modelData.id + '" })')
            }
        }
    }

}
