import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
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

                ColumnLayout {
                    anchors.fill: parent

                    z: 1

                    Column {
                        Layout.fillWidth: true
                        Layout.topMargin: 75

                        spacing: 0

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: Qt.formatTime(clock.date, "h:mm AP").replace(/ (AM|PM)$/, "")
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 128
                            font.letterSpacing: -8
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter

                            text: Qt.formatDate(clock.date, "dddd, MMMM d")
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: 32
                            font.letterSpacing: -2
                        }

                        SystemClock {
                            id: clock
                            precision: SystemClock.Minutes
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Rectangle {
                        id: inputContainer

                        property int attempts: 0

                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: 75

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
                    blurMax: 32
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
