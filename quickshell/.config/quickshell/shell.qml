import Quickshell
import QtQuick
import QtQuick.Layouts

import "./bar"
import "./panels"

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }

    color: Theme.background
    implicitHeight: Dimensions.barHeight

    RowLayout {
        anchors.fill: parent

        Workspaces {}

        Item { Layout.fillWidth: true }

        RowLayout {
            Layout.rightMargin: 16

            Audio { panel: audioPanel }
        }
    }

    DateTime {
        anchors.centerIn: parent
    }

    AudioPanel {
        id: audioPanel
        barWindow: bar
    }
}
