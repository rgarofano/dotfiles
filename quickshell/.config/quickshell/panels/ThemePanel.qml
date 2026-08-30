import Quickshell
import QtQuick
import QtQuick.Layouts

import ".."

PopupWindow {
    id: panel

    property var barWindow

    anchor {
        window: panel.barWindow
        rect.x: panel.barWindow.width - (panel.width / 2)
        rect.y: panel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: content.implicitHeight + 40

    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.width: 2
        border.color: Theme.blue

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 20

            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter

                text: "Themes"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: 600
            }

            Column {
                Layout.fillWidth: true

                Repeater {
                    model: ["Carbon Fox", "Catppuccin Latte"]

                    Rectangle {
                        width: parent.width
                        height: 35
                        color: modelData === Theme.name ? Theme.foreground : "transparent"
                        
                        Text {
                            anchors.centerIn: parent

                            width: Math.min(parent.width - 10, implicitWidth)
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            text: modelData
                            color: modelData === Theme.name ? Theme.background : Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        MouseArea {
                            anchors.fill: parent
                            
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/theme`, modelData])
                        }
                    }
                }
            }
        }
    }
}
