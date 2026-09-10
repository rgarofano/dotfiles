import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

import ".."

Scope {
    id: root

    property var bar

    ListModel {
        id: notifications
    }

    NotificationServer {
        id: server

        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true
            notifications.append({
                image: n.image ? n.image : n.appIcon,
                summary: n.summary,
                body: n.body,
                urgency: n.urgency,
                actions: n.actions,
                createdAt: new Date()
            })
        }
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

    function timeSince(date) {
        const seconds = Math.floor((clock.date - date) / 1000)

        const minutes = Math.floor(seconds / 60)
        if (minutes < 60)
            return minutes + "m ago"

        const hours = Math.floor(minutes / 60)
        if (hours < 24)
            return hours + "h ago"

        const days = Math.floor(hours / 24)
        return days + "d ago"
    }

    PopupWindow {
        id: notificationCenter

        anchor.window: root.bar
        anchor.rect.x: root.bar.width - width / 2
        anchor.rect.y: root.bar.height

        visible: false
        implicitWidth: Dimensions.notificationWidth + 40
        implicitHeight: notificationList.count > 0 ? Math.min(40 + notificationList.contentHeight, 500) : 140
        color: "transparent"

        Rectangle {
            anchors.fill: parent

            color: Theme.background

            ListView {
                id: notificationList

                anchors.fill: parent
                anchors.margins: 20

                model: notifications
                spacing: 10
                focus: true
                width: parent.width

                delegate: Rectangle {
                    width: parent?.width
                    height: 100
                    color: Theme.background
                    border.width: 2
                    border.color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

                    MouseArea {
                        anchors.fill: parent

                        onClicked: notifications.remove(index, 1)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15

                        spacing: 15

                        Image {
                            Layout.preferredWidth: image ? Dimensions.notificationIconSize : 1
                            Layout.preferredHeight: image ? Dimensions.notificationIconSize : 1

                            source: image
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 5

                            Text {
                                Layout.fillWidth: true

                                text: summary
                                color: Theme.blue
                                font.weight: 600
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLarge
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: true

                                text: body
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }
                        }

                        Text {
                            Layout.fillHeight: true

                            text: root.timeSince(createdAt)
                            color: Theme.brightBlack
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeNormal
                        }
                    }

                }
            }

            Text {
                anchors.centerIn: parent

                visible: notificationList.count == 0
                text: "No Notifications"
                color: Theme.brightBlack
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
            }

            Rectangle {
                anchors.fill: parent

                color: "transparent"
                border.width: 2
                border.color: Theme.blue
            }
        }
    }

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    IpcHandler {
        target: "notificationCenter"
        
        function toggle(): void { notificationCenter.visible = !notificationCenter.visible }
    }
}
