import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import ".."
import "../common"

Scope {
    id: root

    required property var barWindow
    readonly property bool isOpen: loader.active

    function open() {
        PanelManager.dispatch(root, () => {
            loader.active = true
            Qt.callLater(() => loader.item?.setFocus(true))
        })

        if (Bluetooth.defaultAdapter?.enabled) {
            Bluetooth.defaultAdapter.discovering = true
        }
    }

    function close() {
        loader.item?.setFocus(false)
        loader.active = false
        PanelManager.remove(root)

        if (Bluetooth.defaultAdapter) {
            Bluetooth.defaultAdapter.discovering = false
        }
    }

    function toggle() {
        if (loader.active) {
            close()
        } else {
            open()
        }
    }

    // Start scanning if Bluetooth gets switched on while the panel is open
    Connections {
        target: Bluetooth.defaultAdapter

        function onEnabledChanged() {
            if (root.isOpen && Bluetooth.defaultAdapter.enabled) {
                Bluetooth.defaultAdapter.discovering = true
            }
        }
    }

    LazyLoader {
        id: loader

        active: false

        PanelWindow {
            id: bluetoothPanel

            readonly property int padding: 20
            readonly property var adapter: Bluetooth.defaultAdapter
            readonly property bool enabled: adapter?.enabled ?? false
            readonly property var devices: Bluetooth.devices?.values ?? []

            readonly property var connectedDevices: devices.filter(d => hasName(d) && d.connected)
            readonly property var pairedDevices: devices.filter(d => hasName(d) && !d.connected && isKnown(d))
            readonly property var availableDevices: adapter?.discovering
                ? devices.filter(d => hasName(d) && !d.connected && !isKnown(d))
                : []

            readonly property var rows: [
                ...connectedDevices.map(d => ({ device: d, section: "Connected" })),
                ...pairedDevices.map(d => ({ device: d, section: "Paired" })),
                ...availableDevices.map(d => ({ device: d, section: "Available" })),
            ]

            property string selected: ""
            readonly property int selectedIndex: rows.findIndex(r => r.device.address === selected)
            readonly property var selectedDevice: selectedIndex >= 0 ? rows[selectedIndex].device : null

            anchors.top: true
            anchors.right: true
            margins.right: 2

            implicitWidth: Dimensions.panelWidth
            implicitHeight: content.implicitHeight + 2 * padding
            color: "transparent"

            function setFocus(focus) {
                if (focus) {
                    keyHandler.forceActiveFocus()
                }
                focusGrab.active = focus
            }

            function isKnown(device) {
                return device.paired || device.bonded || device.trusted
            }

            // Hide devices whose name is empty or just their address
            // (e.g. "4A-1B-75-6C-FE-E2" or "4A:1B:75:6C:FE:E2")
            function hasName(device) {
                const name = String(device.name || device.deviceName || "").trim()
                return name !== "" && !/^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(name)
            }

            function statusText(device) {
                if (device.pairing) {
                    return "Pairing…"
                }
                switch (device.state) {
                    case BluetoothDeviceState.Connecting: return "Connecting…"
                    case BluetoothDeviceState.Disconnecting: return "Disconnecting…"
                }
                if (device.connected) {
                    return device.batteryAvailable ? `${Math.round(device.battery * 100)}%` : "Connected"
                }
                return ""
            }

            function handlePress(device) {
                if (!device || device.pairing) {
                    return
                }

                const action = device.connected ? "disconnect"
                             : isKnown(device)  ? "connect"
                             : "pair"

                Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/bt-device`, action, device.address])
            }

            function forget(device) {
                if (!device || !isKnown(device)) return
                Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/bt-device`, "forget", device.address])
            }

            function move(delta) {
                if (rows.length === 0) return
                const i = selectedIndex < 0
                    ? (delta > 0 ? 0 : rows.length - 1)
                    : Math.max(0, Math.min(rows.length - 1, selectedIndex + delta))
                selected = rows[i].device.address
                deviceList.positionViewAtIndex(i, ListView.Contain)
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, bluetoothPanel]
                onCleared: root.close()
            }

            Rectangle {
                id: frame

                anchors.fill: parent

                color: Theme.background
                border.width: 2
                border.color: Theme.blue

                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.InOutCubic
                    }
                }

                Timer {
                    interval: 50
                    running: true
                    onTriggered: frame.opacity = 1
                }

                ColumnLayout {
                    id: content

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: bluetoothPanel.padding

                    spacing: 15

                    Text {
                        Layout.fillWidth: true

                        visible: deviceList.count === 0
                        text: bluetoothPanel.enabled ? "Searching for devices…" : "Bluetooth is off."
                        color: Theme.brightBlack
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        wrapMode: Text.WordWrap
                    }

                    ListView {
                        id: deviceList

                        readonly property int itemHeight: 50

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                        Layout.maximumHeight: 450

                        visible: count > 0
                        spacing: 5
                        clip: true
                        keyNavigationEnabled: false
                        boundsBehavior: Flickable.StopAtBounds

                        model: bluetoothPanel.rows

                        delegate: ColumnLayout {
                            id: entry

                            required property var modelData
                            required property int index

                            readonly property var device: modelData.device
                            readonly property bool firstInSection: index === 0
                                || bluetoothPanel.rows[index - 1]?.section !== modelData.section
                            readonly property bool isSelected: device.address === bluetoothPanel.selected
                            readonly property string status: bluetoothPanel.statusText(device)

                            width: ListView.view.width
                            spacing: 5

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 1
                                Layout.topMargin: 5

                                visible: entry.firstInSection && entry.index > 0
                                color: Theme.brightBlack
                            }

                            Text {
                                Layout.topMargin: entry.index > 0 ? 5 : 0

                                visible: entry.firstInSection
                                text: entry.modelData.section.toUpperCase()
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal - 2
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: deviceList.itemHeight

                                color: entry.isSelected ? Theme.brightBlack : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10

                                    spacing: 15

                                    Text {
                                        text: entry.device.connected ? "󰂱" : "󰂯"
                                        color: entry.device.connected ? Theme.blue : Theme.foreground
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 24
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter

                                        spacing: 2

                                        Text {
                                            Layout.fillWidth: true

                                            text: entry.device.name || entry.device.deviceName
                                            elide: Text.ElideRight
                                            color: Theme.foreground
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeNormal
                                            font.weight: entry.device.connected ? Font.DemiBold : Font.Normal
                                        }

                                        Text {
                                            Layout.fillWidth: true

                                            visible: entry.status !== ""
                                            text: entry.status
                                            elide: Text.ElideRight
                                            color: entry.device.connected ? Theme.green : Theme.yellow
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSizeNormal - 2
                                        }
                                    }

                                    Text {
                                        visible: entry.isSelected && bluetoothPanel.isKnown(entry.device)
                                        text: "󰅙"
                                        color: forgetMouse.containsMouse ? Theme.red : Theme.foreground
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeLarge

                                        MouseArea {
                                            id: forgetMouse

                                            anchors.fill: parent
                                            z: 1
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: bluetoothPanel.forget(entry.device)
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    z: -1

                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: bluetoothPanel.selected = entry.device.address
                                    onClicked: bluetoothPanel.handlePress(entry.device)
                                }
                            }
                        }
                    }
                }
            }

            Item {
                id: keyHandler

                focus: true

                Keys.onPressed: event => {
                    switch (event.key) {
                    case Qt.Key_J:
                    case Qt.Key_Down:
                        bluetoothPanel.move(1)
                        break
                    case Qt.Key_K:
                    case Qt.Key_Up:
                        bluetoothPanel.move(-1)
                        break
                    case Qt.Key_Return:
                    case Qt.Key_Enter:
                        bluetoothPanel.handlePress(bluetoothPanel.selectedDevice)
                        break
                    case Qt.Key_X:
                    case Qt.Key_Delete:
                        bluetoothPanel.forget(bluetoothPanel.selectedDevice)
                        break
                    case Qt.Key_Escape:
                        root.close()
                        break
                    default:
                        return
                    }
                    event.accepted = true
                }
            }
        }
    }

    IpcHandler {
        target: "bluetoothPanel"

        function toggle(): void { root.toggle() }
    }
}
