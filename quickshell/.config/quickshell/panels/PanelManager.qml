pragma Singleton

import Quickshell
import QtQuick

Singleton {
    property var current: null
    property Timer dispatchTimer: Timer {
        property var openFn
        interval: 100
        onTriggered: openFn()
    }

    function dispatch(panel, openFn) {
        if (current && current !== panel) {
            current.close()
            current = panel
            dispatchTimer.openFn = openFn
            dispatchTimer.restart()
        } else {
            current = panel
            openFn()
        }
    }

    function remove(panel) {
        if (current === panel) {
            current = null
        }
    }
}
