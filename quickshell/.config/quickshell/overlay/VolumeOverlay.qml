import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import ".."

Scope {
    id: root

    property bool show: false
    property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? true

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio

        function onVolumeChanged() {
            root.show = true
            hideTimer.restart()
        }

        function onMutedChanged() {
            root.show = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer

        interval: 1000
        onTriggered: root.show = false
    }

    LazyLoader {
        active: root.show

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 6

            exclusiveZone: 0
            implicitWidth: 350
            implicitHeight: 50
            color: "transparent"
            mask: Region {}

            Rectangle {
                anchors.fill: parent

                color: Theme.background
                border.width: 2
                border.color: Theme.blue

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 15

                    spacing: 15

                    Text {
                        text: root.muted ? "" : ""
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 30
                    }

                    Rectangle {
                        Layout.fillWidth: true            

                        implicitHeight: 10
                        color: Theme.brightBlack

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom

                            implicitWidth: root.muted ? 0 : parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                            color: Theme.foreground
                        }
                    }
                }
            }
        }
    }
}
