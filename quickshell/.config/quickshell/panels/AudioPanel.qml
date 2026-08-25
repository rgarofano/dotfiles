import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import ".."

PopupWindow {
    id: panel

    property var barWindow

    anchor {
        window: panel.barWindow
        rect.x: panel.barWindow.width - (panel.width / 2)
        rect.y: panel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: content.implicitHeight + 40

    color: "transparent"

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
                text: "Output Device"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            Repeater {
                model: Pipewire.nodes

                Rectangle {
                    id: audioDevice

                    property var device: modelData 

                    visible: device.audio && device.isSink && !device.isStream

                    width: parent.width
                    height: 35
                    color: device === Pipewire.defaultAudioSink ? Theme.foreground : "transparent"

                    Text {
                        anchors.centerIn: parent

                        width: implicitWidth > parent.width - 10 ? parent.width - 10 : implicitWidth
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        text: device.description
                        color: device === Pipewire.defaultAudioSink ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    MouseArea {
                        property var device: modelData

                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor
                        onClicked: Pipewire.preferredDefaultAudioSink = device
                    }

                    PwObjectTracker {
                        objects: [audioDevice.device]
                    }
                }
            }

            RowLayout {
                id: slider

                property var sink: Pipewire.defaultAudioSink
                property bool muted: sink?.audio?.muted ?? true
                property real volume: muted ? 0 : sink?.audio?.volume ?? 0

                Layout.topMargin: 10
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
                }

                Text {
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLarge
                    text: `${Math.round(slider.volume * 100)}%`
                    color: Theme.foreground
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20

                text: " Input Device"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.bold: true
            }

            Repeater {
                model: Pipewire.nodes

                Rectangle {
                    property var device: modelData

                    visible: device.audio && !device.isSink && !device.isStream

                    width: parent.width
                    height: 35
                    color: device === Pipewire.defaultAudioSource ? Theme.foreground : "transparent"

                    Text {
                        anchors.centerIn: parent

                        width: implicitWidth > parent.width - 10 ? parent.width - 10 : implicitWidth
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        text: device.description
                        color: device === Pipewire.defaultAudioSource ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: Pipewire.preferredDefaultAudioSource = device
                    }
                }
            }
        }
    }

}
