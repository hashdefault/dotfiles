import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PanelWindow {
    anchors {
        top: true
        right: true
    }
    margins {
        top: 10
        right: 10
    }
    width: 100
    height: 350
    color: "transparent"

    Component.onCompleted: {
        requestActivate()
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationInactive) {
                Qt.quit()
            }
        }
    }

    // Shadow
    Rectangle {
        anchors.fill: mainRect
        anchors.leftMargin: 4
        anchors.topMargin: 4
        color: "#000000"
        opacity: 0.5
        radius: 16
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.rightMargin: 4
        anchors.bottomMargin: 4
        radius: 16
        gradient: Gradient {
             GradientStop { position: 0.0; color: "#0e141c" }
             GradientStop { position: 0.45; color: "#161c24" }
             GradientStop { position: 1.0; color: "#0f2230" }
        }
        border.color: "#1f2c3a"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            component PowerItem : ColumnLayout {
                property string label
                property string icon
                property string command
                property string btnColor: "#e3edff"
                property string activeColor: "#6fc4ff"
                
                spacing: 5
                Layout.alignment: Qt.AlignHCenter

                Process {
                    id: proc
                    command: ["sh", "-c", parent.command]
                    running: false
                }

                Rectangle {
                    width: 50; height: 50
                    radius: 14
                    color: Qt.rgba(255,255,255,0.04)
                    border.color: hoverHandler.hovered ? activeColor : "#223445"
                    border.width: 2
                    Layout.alignment: Qt.AlignHCenter

                    HoverHandler { id: hoverHandler }

                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 24
                        color: hoverHandler.hovered ? activeColor : btnColor
                    }

                    TapHandler {
                        onTapped: {
                            proc.running = false
                            proc.running = true
                        }
                    }
                }

                Text {
                    text: label
                    color: hoverHandler.hovered ? activeColor : "#d7e6ff"
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            PowerItem {
                label: "Shutdown"
                icon: "⏻"
                command: "systemctl poweroff"
                btnColor: "#ff6b6b" // Reddish hint for danger
            }

            PowerItem {
                label: "Reboot"
                icon: ""
                command: "systemctl reboot"
                btnColor: "#ffd93d" // Yellowish
            }

            PowerItem {
                label: "Logout"
                icon: ""
                command: "/home/lucas/.config/eww/scripts/session_exit"
            }

            PowerItem {
                label: "Suspend"
                icon: "󰤄"
                command: "systemctl suspend"
            }
        }
    }
}
