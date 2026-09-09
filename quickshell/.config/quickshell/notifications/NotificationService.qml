import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

import ".."

Scope {
    id: root

    property var bar

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => n.tracked = true
    }

    PopupWindow {
        anchor.window: root.bar
        anchor.rect.x: root.bar.width - width / 2 
        anchor.rect.y: root.bar.height + 5

        visible: server.trackedNotifications.values
        implicitWidth: Dimensions.notificationWidth
        implicitHeight: Math.max(1, content.implicitHeight)
        color: "transparent"

        ColumnLayout {
            id: content

            anchors.fill: parent

            width: parent.width
            spacing: 10

            Repeater {
                model: server.trackedNotifications
                delegate: NotificationItem{}
            }
        }
    }

    PopupWindow {
        id: notificationCenter

        anchor.window: root.bar
        anchor.rect.x: root.bar.width - width / 2
        anchor.rect.y: root.bar.height

        visible: false
        implicitWidth: Dimensions.notificationWidth + 40
        implicitHeight: 500
        color: "transparent"

        Rectangle {
            anchors.fill: parent

            color: Theme.background
            border.width: 2
            border.color: Theme.blue

            ListView {
                id: notificationList

                anchors.margins: 20

                model: server.trackedNotifications
                spacing: 10
                focus: true
                width: parent.width

                delegate: NotificationItem{}
            }

            Text {
                anchors.centerIn: parent

                visible: notificationList.count == 0
                text: "No Notifications"
                color: Theme.brightBlack
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
            }
        }
    }

    IpcHandler {
        target: "notificationCenter"
        
        function toggle(): void { notificationCenter.visible = !notificationCenter.visible }
    }
}
