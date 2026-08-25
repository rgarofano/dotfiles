import QtQuick
import Quickshell
import Quickshell.Io

import ".."

Item {
    id: root
    width: Dimensions.trayItemWidth

    property real output: 0

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    function updateMem() {
        memFile.reload()
        const data = memFile.text()
        const totalKb = Number(data.match(/^MemTotal:\s+(\d+)/m)[1])
        const availableKb = Number(data.match(/^MemAvailable:\s+(\d+)/m)[1])
        output = ((totalKb - availableKb) / totalKb) * 100
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateMem()
    }

    Text {
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeNormal
        color: root.output >= 80 ? Theme.red : Theme.green
        text: `  ${Math.round(root.output)}%`
    }
}
