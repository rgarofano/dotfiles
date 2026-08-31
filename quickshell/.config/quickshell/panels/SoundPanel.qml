import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import ".."

PopupWindow {
    id: soundPanel

    property var sinks: Pipewire.nodes.values.filter(node => node.audio && node.isSink && !node.isStream)
    property var barWindow

    anchor {
        window: soundPanel.barWindow
        rect.x: soundPanel.barWindow.width - (soundPanel.width / 2)
        rect.y: soundPanel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: content.implicitHeight + 40

    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab

        windows: [soundPanel]

        onCleared: {
            soundPanel.visible = false
        }
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

            Text {
                Layout.alignment: Qt.AlignHCenter

                text: "Output Device"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
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

                    Text {
                        anchors.centerIn: parent

                        width: Math.min(parent.width - 10, implicitWidth)
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        text: modelData.description
                        color: modelData === Pipewire.defaultAudioSink ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    PwObjectTracker {
                        objects: [modelData]
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor
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
                    }
                }
            }

            RowLayout {
                id: slider

                readonly property var sink: Pipewire.defaultAudioSink
                readonly property bool muted: sink?.audio?.muted ?? true
                readonly property real volume: muted ? 0 : sink?.audio?.volume ?? 0

                Layout.fillWidth: true
                Layout.topMargin: 10

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
        }
    }

    IpcHandler {
        target: "soundPanel"

        function open(): void {
            soundPanel.visible = true
            focusGrab.active = true
            sinkList.forceActiveFocus()
        }
        function close(): void {
            focusGrab.active = false
            soundPanel.visible = false
        }
        function toggle(): void {
            if (soundPanel.visible) {
                close()
            } else {
                open()
            }
        }
    }
}
