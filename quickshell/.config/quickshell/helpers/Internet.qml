pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var intf: null
    property var ip: null
    property var gateway: null
    property var ssid: null

    Process {
        id: process

        command: [`${Quickshell.env("HOME")}/.local/bin/internet-status`]

        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(text)
                root.intf = data.interface
                root.ip = data.ip
                root.gateway = data.gateway
                root.ssid = data.ssid
            }
        }

    }

    Timer {
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: process.running = true
    }
}
