import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

PopupWindow {
    id: root

    implicitWidth: Dimensions.panelWidth
    implicitHeight: content.implicitHeight + 40

    color: "transparent"

    property var barWindow
    property var audio

    anchor {
        window: root.barWindow
        rect.x:
            (root.barWindow.width
                - Dimensions.dateTimeWidth
                - 2.5 * Dimensions.trayItemWidth
                - 3 * Dimensions.trayItemSpacing)
            - (root.width / 2)
        rect.y: root.barWindow.height
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        border.width: 2
        border.color: Theme.blue

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                text: "  Output Source"
                color: Theme.foreground
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

                        width: parent.width - 10
                        elide: Text.ElideRight
                        maximumLineCount: 1

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
