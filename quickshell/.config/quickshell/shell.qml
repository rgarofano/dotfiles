import Quickshell
import QtQuick
import QtQuick.Layouts

import "./bar"
import "./panels"
import "./notifications"
import "./launcher"
import "./overlay"
import "./lock"

ShellRoot {
    PanelWindow {
        id: bar

        readonly property int shadowSize: 4

        anchors.top: true
        anchors.left: true
        anchors.right: true

        color: "transparent"
        implicitHeight: Dimensions.barHeight + shadowSize
        exclusiveZone: Dimensions.barHeight
        mask: Region { item: barBackground }

        Rectangle {
            id: barBackground

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Dimensions.barHeight

            color: Theme.background
        }

        Rectangle {
            anchors.top: barBackground.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: bar.shadowSize

            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        RowLayout {
            anchors.fill: barBackground

            Workspaces {}

            Item { Layout.fillWidth: true }

            RowLayout {
                Layout.rightMargin: 24

                spacing: 20

                Notifications { panel: notificationCenter }
                Bluetooth { panel: bluetoothPanel }
                Network { panel: networkPanel }
                AudioOutput { panel: soundPanel }
                AudioInput { panel: micPanel }
                SystemResources { panel: systemPanel }
                ThemeSelect { panel: themePanel }
                PowerOptions { panel: powerPanel }
            }
        }

        DateTime {
            anchors.centerIn: barBackground
        }

        NotificationCenter {
            id: notificationCenter
            notificationsModel: notifications
            barWindow: bar
        }

        BluetoothPanel {
            id: bluetoothPanel
            barWindow: bar
        }

        NetworkPanel {
            id: networkPanel
            barWindow: bar
        }

        SoundPanel {
            id: soundPanel
            barWindow: bar
        }

        MicPanel {
            id: micPanel
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

        PowerPanel {
            id: powerPanel
            barWindow: bar
        }
    }

    ListModel {
        id: notifications
    }

    NotificationService {
        notificationsModel: notifications
        barWindow: bar
    }

    AppLauncher {
        barWindow: bar
    }

    VolumeOverlay {
        disabled: soundPanel.isOpen
    }

    Lock {}
}
