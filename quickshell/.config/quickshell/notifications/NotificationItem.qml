import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import ".."

Rectangle {
    id: notification

    property string image: modelData.image ? modelData.image : modelData.appIcon
    property string summary: modelData.summary
    property string body: modelData.body
    property var urgency: modelData.urgency
    property var actions: modelData.actions

    Layout.fillWidth: true

    height: actions.length > 0 ? 135 : 100
    color: Theme.background
    border.width: 2
    border.color: urgency === NotificationUrgency.Critical ? Theme.red : Theme.blue

    MouseArea {
        anchors.fill: parent

        onClicked: modelData.dismiss() 
    }

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
                    color: Theme.blue
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
                Layout.leftMargin: 8
                Layout.rightMargin: 8
                Layout.bottomMargin: 8

                spacing: 5
                visible: notifications.actions.length > 0
        
            Repeater {
                model: notification.actions

                Rectangle {
                    id: button

                    Layout.fillWidth: true

                    height: 25
                    color: Theme.background
                    border.color: Theme.foreground
                    border.width: 2

                    Text {
                        id: buttonText

                        anchors.centerIn: parent

                        text: modelData.text
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        font.weight: 700
                    }

                    MouseArea {
                        anchors.fill: parent

                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.invoke()
                        hoverEnabled: true
                        onEntered: {
                            button.color = Theme.foreground
                            buttonText.color = Theme.background 
                        }
                        onExited: {
                            button.color = Theme.background
                            buttonText.color = Theme.foreground 
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 150 }
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
