import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io

import ".."

Item {
    id: root

    width: Dimensions.trayItemWidth

    property real output: 0
    property double prevTotal: 0
    property double prevIdle: 0

    FileView {
        id: statFile
        path: "/proc/stat"
    }

    function updateCpu() {
        statFile.reload()
        const line = statFile.text().split("\n")[0]
        const fields = line.trim()
                           .split(/\s+/)
                           .slice(1)    // Exclude "cpu" string
                           .map(Number) // Convert from string to number

        const idle = fields[3] + fields[4]
        const total = fields.reduce((sum, value) => sum += value, 0)

        if (prevTotal > 0) {
            const idleDelta = idle - prevIdle
            const totalDelta = total - prevTotal
            output = ((totalDelta - idleDelta) / totalDelta) * 100
        }

        prevIdle = idle
        prevTotal = total
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateCpu()
    }

    Text {
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        color: root.ouput >= 80 ? Theme.red : Theme.blue
        text: `  ${Math.round(root.output)}%`
    }
}
