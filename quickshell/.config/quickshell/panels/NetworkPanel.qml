import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

import ".."
import "../helpers"

PopupWindow {
    id: networkPanel

    required property var barWindow
    property var device: Networking.devices.values.find(d => d.name === Internet.intf)
    property int borderWidth: 2
    property int padding: 15

    anchor {
        window: networkPanel.barWindow
        rect.x: networkPanel.barWindow.width - width / 2
        rect.y: networkPanel.barWindow.height
    }

    implicitWidth:  300
    implicitHeight: 400
    color: "transparent"

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.width: networkPanel.borderWidth
        border.color: Theme.blue

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: networkPanel.padding

            spacing: 10
            
            Text {
                Layout.alignment: Qt.AlignHCenter

                text: {
                    switch(Networking.connectivity) {
                        case NetworkConnectivity.None:
                            return "󰯡  No Network Connection"
                        case NetworkConnectivity.Limited:
                            return "  No Internet Access"
                        case NetworkConnectivity.Full:
                            return "  Internet Access"
                        default:
                            return "  Network Status Unknown"
                    }
                }
                color: {
                    switch(Networking.connectivity) {
                        case NetworkConnectivity.None:
                            return Theme.red
                        case NetworkConnectivity.Limited:
                            return Theme.yellow
                        case NetworkConnectivity.Full:
                            return Theme.green
                        default:
                            return Theme.red
                    }
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal

            }

            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: Theme.brightBlack
            } 

            RowLayout {
                id: interfaceInfo

                Layout.fillWidth: true

                spacing: 15
                visible: Internet.intf

                Text {
                    text: "󰈀"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 50
                }

                ColumnLayout {
                    Text {
                        text: networkPanel.device?.name ?? "N/A"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    Text {
                        text: networkPanel.device ? `${networkPanel.device?.linkSpeed} Mbps` : "N/A"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }

                ColumnLayout {
                    Text {
                        text: Internet.ip ? `󰩟 ${Internet.ip}` : "N/A"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    Text {
                        text: Internet.gateway ? `󱇢 ${Internet.gateway}` : "N/A"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true

                height: 1
                color: Theme.brightBlack
                visible: Internet.intf
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
