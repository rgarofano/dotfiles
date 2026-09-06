pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real percentUsed: 0
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
            percentUsed = ((totalDelta - idleDelta) / totalDelta) * 100
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
}
