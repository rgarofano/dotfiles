import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import ".."

Item {
    id: root

    width: audioText.width
    height: audioText.height

    property var panel

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.sink]
    }

    function volumeIcon() {
        if (root.muted || root.volume === 0) {
            return " "
        } else if (root.volume < 0.33) {
            return " "
        } else if (root.volume < 0.66) {
            return " "
        } else {
            return " "
        }
    }

    Text {
        id: audioText
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.muted ? Theme.red : Theme.yellow
        text: `${volumeIcon()} ${Math.round(root.volume * 100)}%`
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.panel.visible = !root.panel.visible
    }
}
