import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
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
        anchor.rect.y: root.bar.height

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
        if (seconds < 60) {
            return seconds + "s ago"
        }

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

        HyprlandFocusGrab {
            id: focusGrab

            windows: [notificationCenter]
        }

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
                currentIndex: 0

                delegate: Rectangle {
                    id: banner

                    property bool selected: ListView.isCurrentItem

                    width: parent?.width
                    height: 100
                    color: Theme.background
                    border.width: 2
                    border.color: !selected ? Theme.brightBlack
                                    : urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

                    MouseArea {
                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: notificationList.currentIndex = index
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
                            opacity: banner.selected ? 1 : 0.5
                        }

                        ColumnLayout {
                            Layout.fillWidth: true

                            spacing: 5

                            Text {
                                Layout.fillWidth: true

                                text: summary
                                color: !banner.selected ? Theme.brightBlack
                                        : urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue
                                font.weight: 600
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLarge
                                elide: Text.ElideRight

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }

                            Text {
                                Layout.fillWidth: true

                                text: body
                                color: banner.selected ? Theme.foreground : Theme.brightBlack
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeNormal
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                maximumLineCount: 2

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
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

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        currentIndex = Math.min(currentIndex + 1, count - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_K) {
                        currentIndex = Math.max(currentIndex - 1, 0)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                        notifications.remove(currentIndex, 1)
                        if (currentIndex == count) {
                            currentIndex = Math.max(currentIndex - 1, 0)
                        }
                        event.accepted = true
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

        precision: SystemClock.Seconds
    }

    IpcHandler {
        target: "notificationCenter"
        
        function open(): void {
            notificationCenter.visible = true    
            focusGrab.active = true
            notificationList.forceActiveFocus()
        }
        function close(): void {
            notificationCenter.visible = false
            focusbGrab.active = false
        }
        function toggle(): void {
            if (notificationCenter.visible) {
                close()
            } else {
                open()
            }
        }
    }
}
