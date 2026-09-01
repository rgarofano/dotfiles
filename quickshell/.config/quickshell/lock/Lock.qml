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

        onAuthFailure: {
            errorMessage.text = "Incorrect Password"
            passwordInput.clear()
        }
    }

    WlSessionLock {
        id: lock

        locked: false

        WlSessionLockSurface {
            Rectangle {
                id: inputContainer

                anchors.centerIn: parent

                width: 250
                height: 50
                color: Theme.background
                z: 1

                TextInput {
                    id: passwordInput

                    anchors.fill:parent
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10

                    echoMode: TextInput.Password
                    focus: true

                    color: Theme.foreground

                    onTextEdited: lockContext.text = text
                    onAccepted: lockContext.tryUnlock()
                }
            }

            Text {
                id: errorMessage

                anchors {
                    top: inputContainer.bottom
                    horizontalCenter: inputContainer.horizontalCenter
                    topMargin: 10
                }

                text: ""
                color: Theme.red
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                z: 1
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

    IpcHandler {
        target: "lock"

        function activate(): void {
            lock.locked = true
        }
    }
}
