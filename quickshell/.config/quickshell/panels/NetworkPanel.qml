import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

import ".."
import "../services"

PopupWindow {
    id: networkPanel

    property var barWindow

    anchor {
        window: networkPanel.barWindow
        rect.x: networkPanel.barWindow.width - (networkPanel.width / 2)
        rect.y: networkPanel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: 400
    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.width: 2
        border.color: Theme.blue

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10

                text: `Internet Status: ${internet.device ? "Connected" : "Disconnected"}`
                color: internet.device ? Theme.green : Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
            }

            GridLayout {
                id: internet

                property var device: Networking.devices.values.find(
                    d => d.name === Internet.intf
                )

                visible: Internet.intf
                columns: 2
                columnSpacing: 30
                rowSpacing: 5

                Layout.alignment: Qt.AlignHCenter

                Text {
                    Layout.row: 1
                    Layout.column: 0

                    text: `${internet?.device?.type === DeviceType.Wired ? "󰈀" : ""} ${internet?.device?.name}`
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                }

                Text {
                    Layout.row: 2
                    Layout.column: 0

                    text: internet?.device?.type === DeviceType.Wired
                        ? `󰓅 ${internet.device.linkSpeed} Mbps`
                        : ` ${Internet.ssid}`
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                }

                Text {
                    Layout.row: 1
                    Layout.column: 1

                    text: `󰩟 ${Internet.ip}`
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                }

                Text {
                    Layout.row: 2
                    Layout.column: 1

                    text: `󱇢 ${Internet.gateway}`
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    IpcHandler {
        target: "networkPanel"

        function open():   void { networkPanel.visible = true }
        function toggle(): void { networkPanel.visible = !networkPanel.visible }
        function close():  void { networkPanel.visible = false }
    }
}
