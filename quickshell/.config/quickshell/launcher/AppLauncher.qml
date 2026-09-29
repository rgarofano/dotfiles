import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import ".."
import "../panels"

Scope {
    id: root

    required property var barWindow

    function open() {
        PanelManager.dispatch(root, () => {
            loader.active = true
            Qt.callLater(() => loader?.item.setFocus(true))
        })
    }

    function close() {
        loader?.item.setFocus(false)
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
            id: launcher

            property int maxHeight: 490
            property int minHeight: 55

            anchors.top: true 

            implicitWidth: 450
            implicitHeight: content.implicitHeight

            function generateAppList() {
                applications.clear()
                for (const entry of DesktopEntries.applications.values) {
                    const query = input.text.toLowerCase()
                    if (entry.noDisplay || !entry.name.toLowerCase().includes(query)) {
                        continue
                    }
                    applications.append({
                        icon: entry.icon,
                        name: entry.name,
                        command: entry.command.join(),
                        runInTerminal: entry.runInTerminal
                    })
                }
            }

            function setFocus(focus) {
                focusGrab.active = focus
            }

            HyprlandFocusGrab {
                id: focusGrab

                windows: [root.barWindow, launcher]
                onCleared: root.close()
            }

            ListModel {
                id: applications
            }

            Rectangle {
                anchors.fill: parent

                color: Theme.background

                ColumnLayout {
                    id: content

                    anchors.fill: parent

                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.margins: 10

                        height: 35
                        color: Theme.black

                        TextInput {
                            id: input

                            anchors.verticalCenter: parent.verticalCenter

                            width: parent.width
                            padding: 10
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            focus: true

                            onTextEdited: generateAppList()

                            Keys.onPressed: event => {
                                if (event.modifiers === Qt.ControlModifier && event.key === Qt.Key_N) {
                                    appList.currentIndex = Math.min(appList.currentIndex + 1, appList.count - 1)
                                    event.accepted = true
                                } else if (event.modifiers === Qt.ControlModifier && event.key === Qt.Key_P) {
                                    appList.currentIndex = Math.max(appList.currentIndex -1, 0)
                                    event.accpepted = true
                                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                    const app = applications.get(appList.currentIndex)
                                    let command = app.command.split(",")
                                    if (app.runInTerminal) command = ["ghostty", "-e"].concat(command)
                                    Quickshell.execDetached(command)
                                    close()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Escape) {
                                    close()
                                    event.accepted = true
                                }
                            }
                        }
                    }

                    ListView {
                        id: appList

                        readonly property int maxItems: 5
                        readonly property int itemHeight: 60
                        readonly property int gap: 10

                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight
                        Layout.maximumHeight: maxItems * itemHeight + (maxItems - 1) * gap
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.bottomMargin: 10

                        model: applications
                        width: parent.width
                        spacing: gap
                        currentIndex: 0
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            property bool selected: ListView.isCurrentItem

                            width: ListView.view.width
                            height: 60
                            color: selected ? Theme.brightBlack : Theme.black

                            RowLayout {
                                anchors.fill: parent

                                spacing: 20

                                Image {
                                    Layout.preferredWidth: 48
                                    Layout.preferredHeight: 48
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.leftMargin: 10

                                    source: Quickshell.iconPath(icon)
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter

                                    text: name
                                    color: selected ? Theme.blue : Theme.foreground
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeLarge
                                    font.weight: 600
                                }
                            }
                        }
                    }
                }
            }


            Component.onCompleted: generateAppList()
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { root.toggle() }
    }
}
