import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import ".."

Scope {
    id: root

    required property var barWindow
    readonly property bool isOpen: loader.active

    function open() {
        loader.active = true
        Qt.callLater(() => {
            loader.item?.focus()
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
            id: soundPanel

            property var sinks: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)

            anchors.top: true
            anchors.right: true
            margins.right: 2

            implicitWidth: Dimensions.panelWidth
            implicitHeight: 100 + 40 * sinkList.count
            color: "transparent"

            function focus() {
                focusGrab.active = true
                sinkList.forceActiveFocus()
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, soundPanel]
                onCleared: root.close()
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.background
                border.width: 2
                border.color: Theme.blue

                ColumnLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: 20

                    spacing: 15

                    RowLayout {
                        id: slider

                        readonly property var sink: Pipewire.defaultAudioSink
                        readonly property bool muted: sink?.audio?.muted ?? true
                        readonly property real volume: muted ? 0 : sink?.audio?.volume ?? 0

                        Layout.fillWidth: true

                        spacing: 15

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            text: slider.sink && !slider.muted ? " " : ""
                            color: Theme.foreground
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 10
                            color: Theme.brightBlack

                            Rectangle {
                                width: Math.round(slider.volume * parent.width)
                                height: parent.height
                                color: Theme.foreground
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: mouse => {
                                    if (!slider.sink || !slider.sink.audio) { return }
                                    slider.sink.audio.volume = Math.max(0, Math.min(1, mouse.x / width))
                                }
                            }
                        }

                        Text {
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            text: `${Math.round(slider.volume * 100)}%`
                            color: Theme.foreground
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true

                        height: 1
                        color: Theme.brightBlack
                    } 

                    ListView {
                        id: sinkList

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        spacing: 5
                        focus: true
                        currentIndex: 0

                        model: sinks

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 35

                            color: modelData === Pipewire.defaultAudioSink ? Theme.foreground
                                    : ListView.isCurrentItem ? Theme.brightBlack
                                    : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10

                                spacing: 15

                                Text {
                                    Layout.fillHeight: true

                                    text: "󰓃"
                                    verticalAlignment: Text.AlignVCenter
                                    color: modelData === Pipewire.defaultAudioSink ? Theme.background : Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 20
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    text: modelData.description
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    verticalAlignment: Text.AlignVCenter
                                    color: modelData === Pipewire.defaultAudioSink ? Theme.background : Theme.foreground
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
                                onEntered: sinkList.currentIndex = index
                                onClicked: Pipewire.preferredDefaultAudioSink = modelData
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
                                const audio = Pipewire.defaultAudioSink?.audio
                                if (audio) {
                                    const delta = event.modifiers === Qt.ShiftModifier ? 0.01 : 0.05
                                    audio.volume = Math.max(0, audio.volume - delta)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_L) {
                                const audio = Pipewire.defaultAudioSink?.audio
                                if (audio) {
                                    const delta = event.modifiers === Qt.ShiftModifier ? 0.01 : 0.05
                                    audio.volume = Math.min(1, audio.volume + delta)
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                Pipewire.preferredDefaultAudioSink = sinks[currentIndex]
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
    }

    IpcHandler {
        target: "soundPanel"

        function toggle(): void { root.toggle() }
    }
}
