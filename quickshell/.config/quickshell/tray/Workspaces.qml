import Quickshell
import Quickshell.Hyprland
import QtQuick

import ".."

Repeater {
    model: Hyprland.workspaces

    Rectangle {
        property var workspace: modelData

        width: 30
        height: Dimensions.barHeight
        color: workspace.focused ? Theme.brightBlack : Theme.background

        Text {
            anchors.centerIn: parent
            text: workspace.id
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: workspace.focused ? Theme.foreground : Theme.brightBlack
        }

        MouseArea {
            property var workspace: modelData

            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor
            onClicked: workspace.activate()
        }
    }

}
