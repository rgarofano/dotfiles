import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./tray"
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
        anchors.left: parent.left 
        anchors.verticalCenter: parent.verticalCenter

        spacing: 8

        Workspaces {}
    }

    Text {
        anchors.centerIn: parent

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.foreground
        text: Hyprland?.activeToplevel?.title ?? ""
    }

    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 16

        spacing: Dimensions.trayItemSpacing

        Audio { panel: audioPanel }
        CpuPercentage {}
        MemoryUsage {}
        DateTime {}
    }

    AudioPanel {
        id: audioPanel
        barWindow: bar
    }
}
