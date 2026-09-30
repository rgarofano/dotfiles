import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

import ".."

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
            id: powerPanel

            anchors.top: true
            anchors.right: true

            implicitWidth: 150
            implicitHeight: powerList.contentHeight + 4

            function setFocus(focus) {
                if (focus) {
                    powerList.forceActiveFocus()
                }
                focusGrab.active = focus
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, powerPanel]
                onCleared: root.close()
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.background
                border.color: Theme.blue
                border.width: 2

                ListView {
                    id: powerList

                    property var options: ["  Shutdown", "󰑓  Reboot", "  Lock"]
                    property var commands: [
                        ["shutdown", "-h", "now"],
                        ["reboot"],
                        ["qs", "ipc", "call", "lock", "activate"]
                    ]

                    anchors.fill: parent
                    anchors.margins: 2

                    model: options
                    currentIndex: -1
                    focus: true

                    delegate: Rectangle {
                        width: parent.width
                        height: 40

                        color: ListView.isCurrentItem ? Theme.brightBlack : "transparent"

                        Text {
                            anchors.verticalCenter: parent.verticalCenter

                            text: modelData
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            leftPadding: 10
                        }

                        MouseArea {
                            anchors.fill: parent

                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: powerList.currentIndex = index
                            onClicked: () => {
                                if (modelData.includes("Lock")) {
                                    root.close()
                                }
                                Quickshell.execDetached(powerList.commands[index])
                            }
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_J) {
                            currentIndex = Math.min(currentIndex + 1, count - 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_K) {
                            currentIndex = Math.max(currentIndex - 1, 0)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                            if (options[currentIndex].includes("Lock")) {
                                root.close()
                            }
                            Quickshell.execDetached(commands[currentIndex])
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            root.close()
                            event.accepted = true
                        }
                    }
                }
            }

        }

    }

    IpcHandler {
        target: "powerPanel"

        function toggle(): void { root.toggle() }
    }
}
