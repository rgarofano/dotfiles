pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real total: 0
    property real used: 0
    property real percentUsed: 0

    Process {
        id: diskProcess

        command: ["df", "-P", "/"]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                const fields = lines[1].trim().split(/\s+/)
                const usedKib = Number(fields[2])
                const availableKib = Number(fields[3])

                total = availableKib / 1024 / 1024
                used = usedKib / 1024 / 1024
                percentUsed = (total - used) / 100
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true

        onTriggered: {
            diskProcess.running = true
        }
    }
}
