import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import ".."
import "../common"

Scope {
    id: root

    required property var barWindow

    function open() {
        loader.active = true
        Qt.callLater(() => {
            loader?.item.focus()
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
            id: micPanel

            property var microphones: Pipewire.nodes.values.filter(node => node.audio && !node.isSink && !node.isStream)
            readonly property int padding: 20

            anchors.top: true
            anchors.right: true

            implicitWidth: Dimensions.panelWidth
            implicitHeight: content.implicitHeight + 2 * padding
            color: "transparent"

            function focus() {
                focusGrab.active = true
                micList.forceActiveFocus()
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, micPanel]
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
                    }
                }

                Timer {
                    interval: 50
                    running: true
                    triggeredOnStart: true

                    onTriggered: frame.opacity = 1
                }

                ColumnLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: micPanel.padding

                    spacing: 15

                    ListView {
                        id: micList

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        spacing: 5
                        focus: true
                        currentIndex: -1

                        model: microphones

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 35

                            color: modelData === Pipewire.defaultAudioSource ? Theme.foreground
                                    : ListView.isCurrentItem ? Theme.brightBlack
                                    : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10

                                spacing: 10

                                Text {
                                    text: ""
                                    color: modelData === Pipewire.defaultAudioSource ? Theme.background : Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: modelData.description
                                    elide: Text.ElideRight
                                    color: modelData === Pipewire.defaultAudioSource ? Theme.background : Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                }

                            }

                            PwObjectTracker {
                                objects: [modelData]
                            }

                            MouseArea {
                                anchors.fill: parent

                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: micList.currentIndex = index
                                onClicked: Pipewire.preferredDefaultAudioSource = modelData
                            }
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_J) {
                                currentIndex = Math.min(currentIndex + 1, count - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_K) {
                                currentIndex = Math.max(currentIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_H) {
                                const audio = Pipewire.defaultAudioSource?.audio
                                if (audio) {
                                    const delta = event.modifiers === Qt.ShiftModifier ? 0.01 : 0.05
                                    audio.volume = Math.max(0, audio.volume - delta)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_L) {
                                const audio = Pipewire.defaultAudioSource?.audio
                                if (audio) {
                                    const delta = event.modifiers === Qt.ShiftModifier ? 0.01 : 0.05
                                    audio.volume = Math.min(1, audio.volume + delta)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                Pipewire.preferredDefaultAudioSource = microphones[currentIndex]
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.close()
                                event.accepted = true
                            }
                        }
                    }

                    VolumeSlider {
                        node: Pipewire.defaultAudioSource
                        icon: ""
                        mutedIcon: ""
                    }
                }
            }

        }
    }

    IpcHandler {
        target: "micPanel"

        function toggle(): void { root.toggle() }
    }
}
