import QtQuick
import QtQuick.Layouts
import Quickshell
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

                delegate: Rectangle {
                    id: notification

                    property string image: modelData.image ? modelData.image : modelData.appIcon
                    property string summary: modelData.summary
                    property string body: modelData.body
                    property var urgency: modelData.urgency

                    Layout.fillWidth: true

                    height: 100
                    color: Theme.background
                    border.width: 2 
                    border.color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

                    GridLayout {
                        anchors.fill: parent 
                        anchors.margins: 10

                        rows: 3
                        columns: 2
                        rowSpacing: 0
                        columnSpacing: 15

                        Image {
                            Layout.row: 0
                            Layout.column: 0
                            Layout.rowSpan: 3
                            Layout.preferredWidth: notification.image ? Dimensions.notificationIconSize : 1
                            Layout.preferredHeight: notification.image ? Dimensions.notificationIconSize : 1

                            source: notification.image
                        }

                        Text {
                            Layout.row: 0
                            Layout.column: 1
                            Layout.fillWidth: true

                            text: notification.summary
                            color: Theme.foreground
                            font.weight: 600
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.row: 1
                            Layout.column: 1
                            Layout.fillWidth: true
                            Layout.rowSpan: 2

                            text: notification.body
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                            wrapMode: Text.Wrap
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                    }

                    Timer {
                        interval: 5000
                        running: true
                        repeat: false

                        onTriggered: modelData.expire()
                    }
                }
            }
        }
    }
}
