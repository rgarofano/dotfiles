import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import ".."

Scope {
    id: root

    required property var barWindow
    readonly property bool isOpen: loader.active

    function open() {
        PanelManager.dispatch(root, () => {
            loader.active = true
            Qt.callLater(() => loader.item?.setFocus(true))
        })
    }

    function close() {
        loader.item?.setFocus(false)
        loader.active = false
        PanelManager.remove(root)
    }

    function toggle() {
        if (loader.active) {
            close()
        } else {
            open()
        }
    }

    LazyLoader {
        id: loader

        active: false

        PanelWindow {
            id: themePanel

            property var themes: [
                { icon: "󰖔", name: "Carbon Fox" },
                { icon: "", name: "Catppuccin Latte" },
            ]
            readonly property int padding: 20

            anchors.top: true
            anchors.right: true

            implicitWidth: 300
            implicitHeight: content.implicitHeight + 2 * padding
            color: "transparent"

            function setFocus(focus) {
                if (focus) {
                    themeList.forceActiveFocus()
                }
                focusGrab.active = focus
            }

            function setTheme(theme) {
                Quickshell.execDetached([`${Quickshell.env("HOME")}/.local/bin/theme`, theme])
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, themePanel]

                onCleared: root.close()
            }

            Rectangle {
                id: frame

                anchors.fill: parent

                color: Theme.background
                border.width: 2
                border.color: Theme.blue
                opacity: 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Timer {
                    interval: 50
                    running: true
                    onTriggered: frame.opacity = 1
                }

                ColumnLayout {
                    id: content

                    anchors.fill: parent
                    anchors.margins: themePanel.padding

                    ListView {
                        id: themeList

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight

                        spacing: 5
                        focus: true
                        currentIndex: -1
                        model: themes

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 35
                            color: modelData.name === Theme.name ? Theme.foreground : ListView.isCurrentItem ? Theme.brightBlack : "transparent"
                            
                            Text {
                                anchors.centerIn: parent

                                width: Math.min(parent.width - 10, implicitWidth)
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                text: `${modelData.icon}  ${modelData.name}`
                                color: modelData.name === Theme.name ? Theme.background : Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeLarge
                            }

                            MouseArea {
                                anchors.fill: parent
                                
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: themeList.currentIndex = index
                                onClicked: themePanel.setTheme(modelData.name)
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
                                themePanel.setTheme(themes[currentIndex].name)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.close()
                                event.accepted = true
                            }
                        }
                    }
                }
            }

        }
    }

    IpcHandler {
        target: "themePanel"

        function toggle(): void { root.toggle() }
    }
}
