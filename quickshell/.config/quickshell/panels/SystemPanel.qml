import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import ".."
import "../helpers"

Scope {
    id: root

    required property var barWindow
    readonly property bool isOpen: loader.active

    function open() {
        PanelManager.dispatch(root, () => {
            loader.active = true
            Qt.callLater(() => loader.item?.setFocus(true))
        })
    }

    function close() {
        loader.item?.setFocus(false)
        loader.active = false
        PanelManager.remove(root)
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
            id: systemPanel

            readonly property int padding: 20

            anchors.top: true
            anchors.right: true

            implicitWidth: Dimensions.panelWidth
            implicitHeight: content.implicitHeight + 2 * systemPanel.padding
            color: "transparent"

            function setFocus(focus) {
                focusGrab.active = focus
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, systemPanel]
                onCleared: root.close()
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.background
                border.width: 2
                border.color: Theme.blue
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        root.close()
                        event.accepted = true
                    }
                }

                ColumnLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: systemPanel.padding

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

        }
    }

    IpcHandler {
        target: "systemPanel"

        function toggle(): void { root.toggle() }
    }
}
