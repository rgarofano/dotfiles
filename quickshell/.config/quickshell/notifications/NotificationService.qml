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
                    property var actions: modelData.actions

                    Layout.fillWidth: true

                    height: actions.length > 0 ? 130 : 100
                    color: Theme.background
                    border.width: 2 
                    border.color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

                    ColumnLayout {
                        anchors.fill: parent

                        spacing: 5

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 15
                            
                            spacing: 15

                            Image {
                                Layout.preferredWidth: notification.image ? Dimensions.notificationIconSize : 1
                                Layout.preferredHeight: notification.image ? Dimensions.notificationIconSize : 1

                                source: notification.image
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                spacing: 5

                                Text {
                                    Layout.fillWidth: true

                                    text: notification.summary
                                    color: Theme.foreground
                                    font.weight: 600
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLarge
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true

                                    text: notification.body
                                    color: Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeNormal
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                }
                            }
                        }

                        RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 2
                                Layout.rightMargin: 2
                                Layout.bottomMargin: 1

                                spacing: 5
                                visible: notifications.actions.length > 0
                        
                            Repeater {
                                model: notification.actions

                                Rectangle {
                                    Layout.fillWidth: true

                                    height: 25
                                    color: Theme.brightBlack

                                    Text {
                                        anchors.centerIn: parent

                                        text: modelData.text
                                        color: Theme.background
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeNormal
                                        font.weight: 700
                                    }

                                    MouseArea {
                                        anchors.fill: parent

                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.invoke()
                                    }
                                }
                            }
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
