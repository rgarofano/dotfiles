import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import ".."

PopupWindow {
    id: themePanel

    property var themes: ["Carbon Fox", "Catppuccin Latte"]
    property var barWindow

    anchor {
        window: themePanel.barWindow
        rect.x: themePanel.barWindow.width - (themePanel.width / 2)
        rect.y: themePanel.barWindow.height
    }

    implicitWidth: Dimensions.panelWidth
    implicitHeight: themes.length * themeList.contentHeight

    color: "transparent"

    HyprlandFocusGrab {
        id: focusGrab

        windows: [themePanel]

        onCleared: {
            themePanel.visible = false
        }
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.width: 2
        border.color: Theme.blue

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: 20

            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter

                text: "Themes"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: 600
            }

            ListView {
                id: themeList

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 5
                focus: true
                currentIndex: 0
                model: themes

                delegate: Rectangle {
                    width: parent.width
                    height: 35
                    color: modelData === Theme.name ? Theme.foreground : ListView.isCurrentItem ? Theme.brightBlack : "transparent"
                    
                    Text {
                        anchors.centerIn: parent

                        width: Math.min(parent.width - 10, implicitWidth)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        text: modelData
                        color: modelData === Theme.name ? Theme.background : Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLarge
                    }

                    MouseArea {
                        anchors.fill: parent
                        
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/theme`, modelData])
                    }
                }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_J) {
                        currentIndex = Math.min(currentIndex + 1, count - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_K) {
                        currentIndex = Math.max(currentIndex - 1, 0)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/theme`, themes[currentIndex]])
                        event.accepted = true
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "themePanel"

        function open(): void {
            themePanel.visible = true
            focusGrab.active = true
            themeList.forceActiveFocus()
        }
        function close(): void {
            focusGrab.active = false
            themePanel.visible = false
        }
        function toggle(): void {
            if (themePanel.visible) {
                close()
            } else {
                open()
            }
        }
    }
}
