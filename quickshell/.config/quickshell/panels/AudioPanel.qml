import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

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

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "  Output Device"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
            }

            Repeater {
                model: root.outputs

                Rectangle {
                    required property var modelData 

                    width: parent.width
                    height: 35
                    color: modelData === Pipewire.defaultAudioSink ? Theme.foreground : "transparent"

                    Text {
                        anchors.centerIn: parent

                        width: implicitWidth > parent.width - 10 ? parent.width - 10 : implicitWidth
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

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 10
                text: " Input Device"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: 18
                font.bold: true
            }

            Repeater {
                model: root.inputs

                Rectangle {
                    required property var modelData

                    width: parent.width
                    height: 35
                    color: modelData === Pipewire.defaultAudioSource ? Theme.foreground : "transparent"

                    Text {
                        anchors.centerIn: parent

                        width: implicitWidth > parent.width - 10 ? parent.width - 10 : implicitWidth
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        text: modelData.description
                        color: modelData === Pipewire.defaultAudioSource ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: Pipewire.preferredDefaultAudioSource = modelData
                    }
                }
            }
        }
    }

    property var outputs: []
    property var inputs: []

    function updateDevices() {
        const outputs = []
        const inputs = []
        for (const node of Pipewire.nodes.values) {
            if (node.audio && !node.isStream) {
                if (node.isSink) {
                    outputs.push(node)
                } else {
                    inputs.push(node)
                }
            }
        }
        root.outputs = outputs
        root.inputs = inputs
    }

    Component.onCompleted: {
        updateDevices()
    }

    Connections {
        target: Pipewire

        function onReadyChanged() {
            if (Pipewire.ready)
                root.updateDevices()
        }
    }
}
