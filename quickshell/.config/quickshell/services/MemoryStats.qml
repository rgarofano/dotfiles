pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real total: 0
    property real free: 0
    property real used: 0
    property real percentUsed: 0

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    function updateMem() {
        memFile.reload()
        const data = memFile.text()
        if (!data) return
        const totalKib = Number(data.match(/^MemTotal:\s+(\d+)/m)[1])
        const availableKib = Number(data.match(/^MemAvailable:\s+(\d+)/m)[1])
        total = totalKib / 1024 / 1024
        free = availableKib / 1024 / 1024
        used = (totalKib - availableKib) / 1024 / 1024
        percentUsed = (used / total) * 100
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateMem()
    }
}
