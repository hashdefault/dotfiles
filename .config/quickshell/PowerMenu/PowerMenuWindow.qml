import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PanelWindow {
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    Theme { id: theme }

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: mainRect
        width: 500
        height: 160
        anchors.centerIn: parent
        radius: 20
        gradient: Gradient {
             GradientStop { position: 0.0; color: theme.gradientTop }
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.border
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            component PowerItem : ColumnLayout {
                id: powerItemRoot
                property string label
                property string icon
                property string command
                property string color: theme.accent

                spacing: 10
                Layout.alignment: Qt.AlignVCenter

                Process {
                    id: proc
                    command: ["sh", "-c", powerItemRoot.command]
                    running: false
                }

                Rectangle {
                    id: btn
                    width: 80; height: 80
                    radius: 16
                    color: mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : theme.cardBg
                    border.color: mouseArea.containsMouse ? powerItemRoot.color : theme.border
                    border.width: 1
                    Layout.alignment: Qt.AlignHCenter

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 32
                        color: mouseArea.containsMouse ? powerItemRoot.color : theme.text

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            proc.running = true
                        }
                    }
                }

                Text {
                    text: label
                    color: mouseArea.containsMouse ? "#ffffff" : theme.textMuted
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            PowerItem {
                label: "Shutdown"
                icon: "󰐥"
                command: "systemctl poweroff"
                color: theme.red
            }

            PowerItem {
                label: "Reboot"
                icon: "󰜉"
                command: "systemctl reboot"
                color: theme.orange
            }

            PowerItem {
                label: "Logout"
                icon: "󰍃"
                command: "/home/lucas/.config/eww/scripts/session_exit"
                color: theme.purple
            }

            PowerItem {
                label: "Suspend"
                icon: "󰤄"
                command: "systemctl suspend"
                color: theme.green
            }
        }
    }
}
