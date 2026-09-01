import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import ".."

ShellRoot {
    id: root

    LockContext {
        id: lockContext

        onUnlocked: {
            lock.locked = false
        }
    }

    WlSessionLock {
        id: lock

        locked: false

        WlSessionLockSurface {
            color: "transparent"

            Item {
                id: lockContent

                anchors.fill: parent
                opacity: 0

                Component.onCompleted: opacityAnimation.start()

                NumberAnimation {
                    id: opacityAnimation

                    target: lockContent
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 1000
                    easing.type: Easing.InOutCubic
                }

                Column {

                    anchors.centerIn: parent
                    spacing: 500
                    z: 1

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter

                        spacing: 10

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: {
                                const date = new Date()
                                const hours = date.getHours() % 12 || 12
                                return `${hours}:${date.getMinutes().toString().padStart(2, "0")}`
                            }
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 128
                            font.letterSpacing: -8
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 32
                            font.letterSpacing: -2
                        }
                    }

                    Rectangle {
                        id: inputContainer

                        property int attempts: 0

                        anchors.horizontalCenter: parent.horizontalCenter

                        width: 300
                        height: 50
                        color: Theme.background
                        opacity: attempts || passwordInput.text.length ? 0.6 : 0

                        TextInput {
                            id: passwordInput

                            width: Math.min(implicitWidth, parent.width - 20)
                            anchors.centerIn: parent

                            font.pixelSize: Theme.fontSizeLarge
                            echoMode: TextInput.Password
                            focus: true
                            color: Theme.foreground
                            clip: true
                            cursorDelegate: Item {}

                            onTextEdited: () => {
                                lockContext.text = text
                                errorMessage.text = ""
                            }
                            onAccepted: lockContext.tryUnlock()
                        }

                        Text {
                            id: errorMessage

                            anchors {
                                top: passwordInput.bottom
                                horizontalCenter: inputContainer.horizontalCenter
                                topMargin: 30
                            }

                            text: ""
                            color: Theme.red
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                        }

                        Connections {
                            target: lockContext

                            function onAuthFailure() {
                                inputContainer.attempts++
                                errorMessage.text = "Incorrect Password"
                            }
                        }
                    }
                }

                Image {
                    id: wallpaper

                    anchors.fill: parent
                    source: `file://${Quickshell.env("HOME")}/dotfiles/themes/${Theme.name}/wallpaper.png`
                    fillMode: Image.PreserveAspectCrop
                    z: 0
                }

                MultiEffect {
                    anchors.fill: parent
                    source: wallpaper
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 48
                }
            }
        }
    }

    IpcHandler {
        target: "lock"

        function activate(): void {
            lock.locked = true
        }
    }
}
