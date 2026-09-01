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

                Rectangle {
                    id: inputContainer

                    anchors.centerIn: parent

                    width: 300
                    height: 50
                    color: Theme.background
                    z: 1

                    TextInput {
                        id: passwordInput

                        width: Math.min(implicitWidth, parent.width - 20)
                        anchors.centerIn: parent

                        font.pixelSize: Theme.fontSizeLarge
                        echoMode: TextInput.Password
                        focus: true
                        color: Theme.foreground
                        clip: true

                        onTextEdited: lockContext.text = text
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
                        z: 1
                    }

                    Connections {
                        target: lockContext

                        function onAuthFailure() {
                            passwordInput.clear()
                            errorMessage.text = "Incorrect Password"
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
