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
            font.pixelSize: Theme.fontSizeNormal
            color: workspace.focused ? Theme.foreground : Theme.brightBlack

            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }

        Rectangle {
            property var workspace: modelData

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            visible: workspace.focused
            height: 3
            color: Theme.blue
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            property var workspace: modelData

            anchors.fill: parent

            cursorShape: Qt.PointingHandCursor
            onClicked: workspace.activate()
        }
    }
}
