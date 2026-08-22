import QtQuick
import Quickshell
import Quickshell.Io

import ".."

Item {
    id: root
    width: memText.width

    property real output: 0

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    function updateMem() {
        memFile.reload()
        const data = memFile.text()
        const totalKb = data.match(/^MemTotal:\s+(\d+)/m)[1]
        const availableKb = data.match(/^MemAvailable:\s+(\d+)/m)[1]
        output = (Number(totalKb) - Number(availableKb)) / 1000000
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.updateMem()
    }

    Text {
        id: memText
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.green
        text: `  ${root.output.toFixed(1)} GB`
    }
}
