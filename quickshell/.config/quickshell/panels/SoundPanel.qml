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
            property int padding: 20
            property int globalIndex: -1
            readonly property int globalCount: mixerList.count + sinkList.count
            property var currentSink: null

            anchors.top: true
            anchors.right: true
            margins.right: 2

            implicitWidth: Dimensions.panelWidth
            implicitHeight: content.implicitHeight + 2 * padding
            color: "transparent"

            function focus() {
                focusGrab.active = true
            }

            function setCurrentSink() {
                if (globalIndex < mixerList.count) {
                    currentSink = mixerList.model[mixerList.currentIndex].source
                } else {
                    currentSink = sinkList.model[sinkList.currentIndex]
                }
            }

            function navigate(delta) {
                if (delta > 0) {
                    globalIndex = Math.min(globalIndex + delta, globalCount - 1)
                } else {
                    globalIndex = Math.max(0, globalIndex + delta)
                }
                setCurrentSink()
            }

            function adjustVolume(delta) {
                const audio = currentSink.audio
                if (!audio) {
                    return
                }

                if (delta > 0) {
                    audio.volume = Math.min(audio.volume + delta / 100, 1)
                } else {
                    audio.volume = Math.max(0, audio.volume + delta / 100)
                }
            }

            function handleEnter() {
                if (globalIndex < mixerList.count) {
                    if (currentSink.audio) {
                        currentSink.audio.muted = !currentSink.audio.muted
                    }
                } else {
                    Pipewire.preferredDefaultAudioSink = currentSink
                }
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, soundPanel]
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
                        easing.type: Easing.InOutCubic
                    }
                }

                Timer {
                    interval: 50
                    running: true
                    onTriggered: frame.opacity = 1
                }

                ColumnLayout {
                    id: content

                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: soundPanel.padding

                    spacing: 15

                    PwNodeLinkTracker {
                        id: linkTracker

                        node: Pipewire.defaultAudioSink
                    }

                    ListView {
                        id: mixerList

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        model: linkTracker.linkGroups
                        currentIndex: soundPanel.globalIndex < count ? soundPanel.globalIndex : -1
                        spacing: 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: ColumnLayout {
                            readonly property var props: modelData.source.properties

                            width: ListView.view.width
                            spacing: 10

                            Rectangle {
                                Layout.fillWidth: true

                                height: 35
                                color: index === mixerList.currentIndex ? Theme.brightBlack : "transparent"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 20
                                    anchors.rightMargin: 20

                                    spacing: 10

                                    Image {
                                        sourceSize.width: 16
                                        sourceSize.height: 16

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
                            }

                            VolumeSlider {
                                Layout.fillWidth: true

                                node: modelData.source
                            }
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1

                        visible: mixerList.count > 0
                        color: Theme.brightBlack
                    } 

                    ListView {
                        id: sinkList

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        spacing: 5
                        currentIndex: soundPanel.globalIndex >= mixerList.count ? soundPanel.globalIndex - mixerList.count : -1

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
                    }

                    VolumeSlider {
                        Layout.fillWidth: true 

                        node: Pipewire.defaultAudioSink
                    }
                }
            }

            Item {
                focus: true

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        soundPanel.navigate(1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_K) {
                        soundPanel.navigate(-1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_H) {
                        const delta = event.modifiers === Qt.ShiftModifier ? -1 : -5
                        soundPanel.adjustVolume(delta)
                        event.accepted = true
                    } else if (event.key === Qt.Key_L) {
                        const delta = event.modifiers === Qt.ShiftModifier ? 1 : 5
                        soundPanel.adjustVolume(delta)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Return) {
                        soundPanel.handleEnter()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.close()
                        event.accepted = true
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
