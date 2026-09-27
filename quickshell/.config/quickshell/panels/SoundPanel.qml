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
            implicitHeight: 160 + 40 * sinkList.count + 75 * mixer.count
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

                    PwNodeLinkTracker {
                        id: linkTracker

                        node: Pipewire.defaultAudioSink
                    }

                    Repeater {
                        id: mixer

                        model: linkTracker.linkGroups

                        ColumnLayout {
                            readonly property var props: modelData.source.properties

                            Layout.fillWidth: true

                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true

                                spacing: 10
                                
                                Item { Layout.fillWidth: true }

                                Image {
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24

                                    source: {
                                        const direct = Quickshell.iconPath(props["application.icon-name"] || "", true)
                                        if (direct) return direct
                                        const key = props["application.process.binary"] || props["application.name"] || ""
                                        const entry = DesktopEntries.heuristicLookup(key)
                                        if (entry) {
                                            const fromEntry = Quickshell.iconPath(entry.icon, true)
                                            if (fromEntry) return fromEntry
                                        }
                                        return `image://icon/${props["application.icon-name"]}`
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: `${props["application.name"]} - ${props["media.name"]}`
                                    elide: Text.ElideRight
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                }
                            }

                            VolumeSlider {
                                Layout.fillWidth: true

                                node: modelData.source
                            }
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
                        currentIndex: -1

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

                    VolumeSlider {
                        Layout.fillWidth: true 

                        node: Pipewire.defaultAudioSink
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
