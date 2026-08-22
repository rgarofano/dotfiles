import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

PopupWindow {
    id: root

    implicitWidth: 600
    implicitHeight: 250

    color: "transparent"

    property var barWindow
    anchor {
        window: root.barWindow
        rect.y: root.barWindow.height
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: "Output"
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
            }

            Repeater {
                model: root.sinks

                Rectangle {
                    required property var modelData 

                    width: parent.width
                    height: 45
                    color: modelData === Pipewire.defaultAudioSink ? Theme.foreground : "transparent"

                    Text {
                        anchors.centerIn: parent

                        text: modelData.description
                        color: modelData === Pipewire.defaultAudioSink ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                    }
                }
            }
        }
    }

    property var sinks: []

    function updateSinks() {
        const result = []
        for (const node of Pipewire.nodes.values) {
            if (node.audio && node.isSink && !node.isStream) {
                result.push(node)
            }
        }
        root.sinks = result
    }

    Component.onCompleted: {
        updateSinks()
    }

    Connections {
        target: Pipewire

        function onReadyChanged() {
            if (Pipewire.ready)
                root.updateSinks()
        }
    }
}
