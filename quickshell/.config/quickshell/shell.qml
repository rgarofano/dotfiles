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
            Layout.rightMargin: 24

            spacing: 16

            Audio { panel: audioPanel }
            SystemResources { panel: systemPanel }
            ThemeSelect { panel: themePanel }
        }
    }

    DateTime {
        anchors.centerIn: parent
    }

    AudioPanel {
        id: audioPanel
        barWindow: bar
    }

    SystemPanel {
        id: systemPanel
        barWindow: bar
    }

    ThemePanel {
        id: themePanel
        barWindow: bar
    }
}
