import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Effects

import ".."

Item {
    id: root

    width: Dimensions.trayItemWidth
    height: Dimensions.barHeight

    property var panel

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    PwObjectTracker {
        objects: [root.sink]
    }

    Text {
        id: audioText
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.muted ? Theme.red : Theme.yellow
        text: ` ${Math.round(root.volume * 100)}%`
    }

    MouseArea {
        anchors.fill: parent
        onClicked: () => {
            root.panel.visible = !root.panel.visible
            glowEffect.shadowEnabled = !glowEffect.shadowEnabled
        }
    }

    MultiEffect {
        id: glowEffect
        source: audioText
        anchors.fill: audioText
        shadowEnabled: false
        shadowColor: "white"
        shadowBlur: 1.0
        shadowOpacity: 1.0
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
    }
}
