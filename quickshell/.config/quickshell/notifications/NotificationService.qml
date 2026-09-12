import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications

import ".."

Scope {
    id: root

    required property var barWindow
    required property ListModel notificationsModel

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true
            notificationsModel.append({
                image: n.image ? n.image : n.appIcon,
                summary: n.summary,
                body: n.body,
                urgency: n.urgency,
                createdAt: new Date()
            })
        }
    }

    PopupWindow {
        anchor.window: root.barWindow
        anchor.rect.x: root.barWindow.width - width / 2 
        anchor.rect.y: root.barWindow.height

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
}
