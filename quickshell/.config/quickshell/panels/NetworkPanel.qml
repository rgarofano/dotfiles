import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

import ".."
import "../helpers"

Scope {
    id: root

    required property var barWindow
    readonly property bool isOpen: loader.active

    function open() {
        loader.active = true
        Qt.callLater(() => {
            loader.item.focus()
        })
    }

    function close() {
        loader.active = false
    }

    function toggle() {
        if (loader.active) {
            close()
        } else {
            open()
        }
    }

    LazyLoader {
        id: loader

        active: false

        PanelWindow {
            id: networkPanel

            property var device: Networking.devices.values.find(d => d.name === Internet.intf)
            property int borderWidth: 2
            property int padding: 15

            anchors.top: true
            anchors.right: true
            margins.right: 2

            implicitWidth:  300
            implicitHeight: content.implicitHeight + 2 * padding
            color: "transparent"

            function focus() {
                focusGrab.active = true
                networkList.forceActiveFocus()
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, networkPanel]
                onCleared: root.close()
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.background
                border.width: networkPanel.borderWidth
                border.color: Theme.blue

                ColumnLayout {
                    id: content

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

                    ListView {
                        id: networkList

                        Layout.fillWidth: true

                        property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi)
                        readonly property int itemHeight: 50
                        readonly property int maxItems: 5

                        model: device.networks
                        spacing: 10
                        implicitHeight: Math.min(contentHeight, maxItems * itemHeight + (maxItems - 1) * itemHeight)
                        currentIndex: 0
                        
                        delegate: Rectangle {
                            width: networkList.width
                            height: networkList.itemHeight
                            color: ListView.isCurrentItem ? Theme.brightBlack : Theme.background
                            
                            RowLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 10

                                spacing: 10
                                clip: true

                                Text {
                                    Layout.alignment: Qt.AlignVCenter

                                    text: " "
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLarge
                                }

                                Text {
                                    text: modelData.name
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                    elide: Text.ElideRight
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor 
                                hoverEnabled: true
                                onEntered: networkList.currentIndex = index
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_J) {
                                currentIndex = Math.min(currentIndex + 1, count - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_K) {
                                currentIndex = Math.max(currentIndex - 1, 0)
                                event.accepted = true
                            }
                        }

                        Component.onCompleted: {
                            if (device) {
                                device.scannerEnabled = true
                            }
                        }
                    }
                }
            }

        }
    }

    IpcHandler {
        target: "networkPanel"

        function toggle(): void { root.toggle() }
    }
}
