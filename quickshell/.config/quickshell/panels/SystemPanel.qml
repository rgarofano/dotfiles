import Quickshell
import QtQuick
import QtQuick.Layouts

import ".."
import "../services"

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
                text: "System Resources"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 10

                Text {
                    text: " "
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.foreground
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((CpuStats.percentUsed / 100) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${CpuStats.percentUsed.toFixed(1)} %`
                    color: Theme.foreground
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 15

                Text {
                    text: ""
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.foreground
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((MemoryStats.percentUsed / 100) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${MemoryStats.used.toFixed(1)} GiB`
                    color: Theme.foreground
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 15

                Text {
                    text: "󰋊 "
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    color: Theme.foreground
                }

                Rectangle {
                    Layout.fillWidth: true

                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((DiskStats.percentUsed / 100) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${DiskStats.used.toFixed(1)} GiB`
                    color: Theme.foreground
                }
            }
        }
    }
}
