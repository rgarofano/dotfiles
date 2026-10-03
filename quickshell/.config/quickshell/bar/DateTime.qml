import QtQuick
import Quickshell

import ".."

Text {
    id: clockText

    text: Qt.formatDateTime(clock.date, "ddd h:mm AP")
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSizeNormal
    font.weight: 600

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    HoverHandler { id: hover }

    PopupWindow {
        anchor.item: clockText
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.margins.top: 8

        implicitWidth: fullDate.implicitWidth + 24
        implicitHeight: fullDate.implicitHeight + 12
        visible: hover.hovered
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            border.color: Theme.blue
            border.width: 2

            Text {
                id: fullDate

                anchors.centerIn: parent

                text: Qt.formatDate(clock.date, "MMMM d, yyyy")
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
            }
        }
    }
}
