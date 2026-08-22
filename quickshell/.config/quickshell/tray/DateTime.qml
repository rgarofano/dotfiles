import QtQuick
import Quickshell

import ".."

Item {
    width: dateText.width

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: dateText
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.foreground
        text: Qt.formatDateTime(clock.date, "ddd MMM d h:mm AP")
    }
}
