import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

import ".."

PopupWindow {
    id: powerPanel

    property var barWindow

    anchor.window: barWindow
    anchor.rect.x: barWindow.width - width / 2
    anchor.rect.y: barWindow.height

    implicitWidth: 150
    implicitHeight: powerList.contentHeight + 4

    function open() {
        powerPanel.visible = true
        focusGrab.active = true
        powerList.forceActiveFocus()
    }

    function close() {
        focusGrab.active = false
        powerPanel.visible = false
    }
    
    function toggle() {
        if (powerPanel.visible) {
            close()
        } else {
            open()
        }
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [powerPanel.barWindow, powerPanel]
        onCleared: powerPanel.visible = false
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
            currentIndex: 0
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
                            powerPanel.close()
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
                        powerPanel.close()
                    }
                    Quickshell.execDetached(commands[currentIndex])
                    event.accepted = true
                } else if (event.key === Qt.Key_Escape) {
                    powerPanel.close()
                    event.accepted = true
                }
            }
        }
    }

    IpcHandler {
        target: "powerPanel"

        function toggle(): void { powerPanel.toggle() }
    }
}
