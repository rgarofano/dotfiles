import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

import ".."

PopupWindow {
    id: launcher

    required property var barWindow
    property int maxHeight: 490
    property int minHeight: 55

    anchor.window: barWindow
    anchor.rect.x: barWindow.width / 2 - width / 2
    anchor.rect.y: barWindow.height

    implicitWidth: 450
    implicitHeight: Math.min(maxHeight, minHeight + 75 * appList.count)
    visible: false

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

    function open() {
        launcher.visible = true
        focusGrab.active = true
    }

    function close() {
        focusGrab.active = false
        launcher.visible = false
        input.clear()
        generateAppList()
    }

    function toggle() {
        if (launcher.visible) {
            close()
        } else {
            open()
        }
    }

    HyprlandFocusGrab {
        id: focusGrab

        windows: [launcher.barWindow, launcher]
        onCleared: launcher.visible = false
        
    }

    ListModel {
        id: applications
    }

    Rectangle {
        anchors.fill: parent

        color: Theme.background
        border.color: Theme.blue
        border.width: 2

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

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 10

                model: applications
                width: parent.width
                spacing: 10
                currentIndex: 0
                clip: true

                delegate: Rectangle {
                    property bool selected: ListView.isCurrentItem

                    width: ListView.view.width
                    height: 60
                    color: selected ? Theme.blue : Theme.black

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
                            color: selected ? Theme.background : Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLarge
                            font.weight: 600
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { launcher.toggle() }
    }

    Component.onCompleted: generateAppList()
}
