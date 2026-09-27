import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

import ".."

RowLayout {
    id: root

    required property var node
    property string icon: "\uf028"
    property string mutedIcon: "\uf026"
    property real step: 0.05

    readonly property bool muted: node?.audio?.muted ?? true
    readonly property real volume: node?.audio?.volume ?? 0

    function setVolume(v) {
        if (node?.audio) {
            node.audio.volume = Math.max(0, Math.min(1, v))
        }
    }

    function toggleMute() {
        if (node?.audio) node.audio.muted = !node.audio.muted
    }

    spacing: 15

    PwObjectTracker {
        objects: root.node ? [root.node] : []
    }

    Text {
        text: root.muted ? root.mutedIcon : root.icon
        color: root.muted ? Theme.brightBlack : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleMute()
        }
    }

    Item {
        id: track

        Layout.fillWidth: true
        Layout.preferredHeight: knob.height

        readonly property real usable: width - knob.width

        Rectangle {
            id: groove
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 6
            color: Theme.brightBlack

            Rectangle {
                width: knob.x + knob.width / 2
                height: parent.height
                color: Theme.foreground
                opacity: root.muted ? 0.35 : 1
            }
        }

        Rectangle {
            id: knob
            width: 14
            height: 14
            x: root.volume * track.usable
            anchors.verticalCenter: parent.verticalCenter

            color: root.muted ? Theme.brightBlack : Theme.foreground
            border.width: 2
            border.color: mouse.containsMouse || mouse.pressed ? Theme.blue : Theme.background
            scale: mouse.pressed ? 1.2 : 1

            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: Qt.PointingHandCursor

            function seek(mx) {
                root.setVolume((mx - knob.width / 2) / track.usable)
            }

            onPressed: m => seek(m.x)
            onPositionChanged: m => { if (pressed) seek(m.x) }
            onWheel: w => root.setVolume(root.volume + (w.angleDelta.y > 0 ? root.step : -root.step))
        }
    }

    TextMetrics {
        id: pctMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge
        text: "100%"
    }

    Text {
        Layout.preferredWidth: pctMetrics.width
        horizontalAlignment: Text.AlignRight
        text: `${Math.round(root.volume * 100)}%`
        color: root.muted ? Theme.brightBlack : Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeLarge
    }
}
