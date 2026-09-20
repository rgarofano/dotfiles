import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import ".."
import "../helpers"

PopupWindow {
    id: systemPanel

    property var barWindow

    anchor {
        window: systemPanel.barWindow
        rect.x: systemPanel.barWindow.width - width / 2
        rect.y: systemPanel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: content.implicitHeight + 40
    color: "transparent"

    function open() {
        systemPanel.visible = true
        focusGrab.active = true
    }

    function close() {
        focusGrab.active = false
        systemPanel.visible = false
    }

    function toggle() {
        if (systemPanel.visible) {
            close()
        } else {
            open()
        }
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [systemPanel.barWindow, systemPanel]
        onCleared: systemPanel.close()
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.width: 2
        border.color: Theme.blue
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                systemPanel.close()
                event.accepted = true
            }
        }

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
                    Layout.fillWidth: true

                    text: " "
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.foreground
                }

                Rectangle {
                    width: Dimensions.panelWidth - 180
                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((System.cpuUsagePercent / 100) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    Layout.fillWidth: true

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${System.cpuUsagePercent.toFixed(1)} %`
                    color: Theme.foreground
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 10

                Text {
                    Layout.fillWidth: true
                    Layout.rightMargin: 9

                    text: " "
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    color: Theme.foreground
                }

                Rectangle {
                    width: Dimensions.panelWidth - 180
                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((System.usedMemory / System.totalMemory) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${System.usedMemory.toFixed(1)} GiB`
                    color: Theme.foreground
                }
            }

            RowLayout {
                Layout.fillWidth: true

                spacing: 10

                Text {
                    Layout.fillWidth: true
                    Layout.rightMargin: 10

                    text: "󰋊 "
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    color: Theme.foreground
                }

                Rectangle {
                    width: Dimensions.panelWidth - 180
                    height: 10
                    color: Theme.brightBlack

                    Rectangle {
                        width: Math.round((System.usedStorage / System.totalStorage) * parent.width)
                        height: 10
                        color: Theme.foreground
                    }
                }

                Text {
                    Layout.fillWidth: true

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${System.usedStorage.toFixed(1)} GiB`
                    color: Theme.foreground
                }
            }
        }
    }

    IpcHandler {
        target: "systemPanel"

        function toggle(): void { systemPanel.toggle() }
    }
}
