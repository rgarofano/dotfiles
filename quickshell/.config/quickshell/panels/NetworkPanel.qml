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
            property var wifiNetwork: device?.networks.values.find(n => n.name === Internet.ssid)
            property int borderWidth: 2
            property int padding: 15
            property bool promptPassword: false
            property bool connecting: false
            property var selectedNetwork: null
            property string errorText: ""

            anchors.top: true
            anchors.right: true
            margins.right: 2

            implicitWidth: Dimensions.panelWidth
            implicitHeight: contentLoader.implicitHeight + 2 * padding
            color: "transparent"

            function focus() {
                focusGrab.active = true
            }

            function toggleConnection(network) {
                selectedNetwork = network
                if (selectedNetwork.connected) {
                    selectedNetwork.disconnect()
                } else {
                    selectedNetwork.connect()
                }
            }

            function reset() {
                if (connecting) {
                    return
                }
                promptPassword = false
            }

            Connections {
                target: networkPanel.selectedNetwork

                function onConnectionFailed(reason) {
                    if (networkPanel.connecting) {
                        switch (reason) {
                            case ConnectionFailReason.NoSecrets:
                            case ConnectionFailReason.WifiClientFailed:
                                networkPanel.errorText = "Incorrect Password"
                                break
                            case ConnectionFailReason.WifiAuthTimeout:
                                networkPanel.errorText = "Authentication Timed Out"
                                break
                            case ConnectionFailReason.WifiNetworkLost:
                                networkPanel.errorText = "Network Lost"
                                break
                            default:
                                networkPanel.errorText = "Connection Failed"
                        }
                        networkPanel.connecting = false
                    }
                    else if (reason === ConnectionFailReason.NoSecrets) {
                        networkPanel.promptPassword = true
                    }
                }

                function onConnectedChanged() {
                    if (networkPanel.selectedNetwork.connected) {
                        networkPanel.connecting = false
                        networkPanel.reset()
                    }
                }
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
                
                Loader {
                    id: contentLoader

                    anchors.fill: parent
                    anchors.margins: networkPanel.padding

                    focus: true
                    sourceComponent: networkPanel.promptPassword ? passwordView : networksView
                }
            }

            Component {
                id: networksView

                ColumnLayout {
                    id: content

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

                        spacing: 20
                        visible: Internet.intf

                        Item { Layout.fillWidth: true }

                        Text {
                            text: networkPanel.device?.type === DeviceType.Wired ? "󰈁" : "󰑩"
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
                                text: networkPanel.device?.type === DeviceType.Wired ? `${networkPanel.device?.linkSpeed} Mbps`
                                                                                     : `  ${100 * networkPanel.wifiNetwork?.signalStrength ?? 0}%`
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

                        Item { Layout.fillWidth: true }
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
                        focus: true
                        currentIndex: 0
                        
                        delegate: Rectangle {
                            width: networkList.width
                            height: networkList.itemHeight
                            color: ListView.isCurrentItem ? Theme.brightBlack : Theme.background
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                spacing: 15

                                Text {
                                    Layout.alignment: Qt.AlignVCenter

                                    text: ""
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLarge
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter

                                    spacing: 2

                                    Text {
                                        Layout.fillWidth: true

                                        text: modelData.name
                                        color: Theme.foreground
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeNormal
                                        font.weight: modelData.connected ? Font.Bold : Font.Normal
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true

                                        visible: modelData.connected
                                        text: "Connected"
                                        color: Theme.green
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeNormal - 2
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor 
                                hoverEnabled: true
                                onEntered: networkList.currentIndex = index
                                onClicked: networkPanel.toggleConnection(networkList.model.values[index])
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_J) {
                                currentIndex = Math.min(currentIndex + 1, count - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_K) {
                                currentIndex = Math.max(currentIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                networkPanel.toggleConnection(model.values[currentIndex])
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.close()
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

            Component {
                id: passwordView
                
                ColumnLayout {
                    anchors.fill: parent

                    spacing: 10

                    Item { Layout.fillHeight: true }

                    Text {
                        Layout.fillWidth: true

                        text: ""
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 50
                        horizontalAlignment: Text.AlignHCenter

                        transform: Translate {
                            x: -15
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: networkPanel.selectedNetwork.name
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 10
                        Layout.preferredHeight: 28
                        
                        color: Theme.brightBlack

                        RowLayout {
                            anchors.fill: parent

                            spacing: 5

                            Text {
                                Layout.fillHeight: true
                                Layout.leftMargin: 5

                                text: ""
                                verticalAlignment: Qt.AlignVCenter
                                opacity: 0.5
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLarge
                            }

                            TextInput {
                                id: passwordInput

                                Layout.fillHeight: true
                                Layout.fillWidth: true

                                width: parent.width
                                padding: 2
                                focus: true
                                echoMode: TextInput.Password
                                clip: true
                                verticalAlignment: Qt.AlignVCenter
                                readOnly: networkPanel.connecting
                                onTextEdited: networkPanel.errorText = ""
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                font.letterSpacing: 1.5

                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        networkPanel.selectedNetwork.connectWithPsk(passwordInput.text)
                                        networkPanel.connecting = true
                                        event.accepted = true
                                    } else if (event.key === Qt.Key_Escape) {
                                        networkPanel.reset()
                                        event.accepted = true
                                    }
                                }
                            }
                        }

                        Item {
                            id: progressTrack

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            clip: true
                            visible: networkPanel.connecting

                            Rectangle {
                                id: bar
                                width: progressTrack.width * 0.3
                                height: parent.height
                                color: Theme.blue

                                NumberAnimation on x {
                                    from: -bar.width
                                    to: progressTrack.width
                                    duration: 1000
                                    easing.type: Easing.InOutQuad
                                    loops: Animation.Infinite
                                    running: progressTrack.visible
                                }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        visible: networkPanel.errorText    
                        text: networkPanel.errorText
                        horizontalAlignment: Text.AlignHCenter
                        color: Theme.red
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    IpcHandler {
        target: "networkPanel"

        function toggle(): void { root.toggle() }
    }
}
