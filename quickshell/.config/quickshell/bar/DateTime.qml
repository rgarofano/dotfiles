import QtQuick
import Quickshell

import ".."

Text {
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeNormal
    color: Theme.foreground
    text: Qt.formatDateTime(clock.date, "ddd h:mm AP")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
