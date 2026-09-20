pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuUsagePercent: 0
    property real totalMemory: 0
    property real usedMemory: 0
    property real totalStorage: 0
    property real usedStorage: 0

    Process {
        id: process

        command: [`${Quickshell.env("HOME")}/.local/bin/system-resources`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(text)
                root.cpuUsagePercent = data.cpuUsage / 100
                root.totalMemory = data.totalMemoryKiB / 1024 / 1024
                root.usedMemory = data.usedMemoryKiB / 1024 / 1024
                root.totalStorage = data.totalStorageKiB / 1024 / 1024
                root.usedStorage = data.usedStorageKiB / 1024 / 1024
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: process.running = true
    }
}
