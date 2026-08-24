import QtQuick
import Quickshell

import ".."

Item {
    width: Dimensions.dateTimeWidth

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.foreground
        text: Qt.formatDateTime(clock.date, "ddd h:mm AP")
    }
}
