import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

Item {
    id: root

    width: 50
    height: 30

    property var panel

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.sink]
    }

    Text {
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.muted ? Theme.red : Theme.yellow
        text: ` ${Math.round(root.volume * 100)}%`
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.panel.visible = !root.panel.visible
    }
}
