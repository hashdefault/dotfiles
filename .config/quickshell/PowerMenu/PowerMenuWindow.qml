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

    // Background to catch clicks and close (optional, but good for UX)
    MouseArea {
        anchors.fill: parent
        onClicked: {
            // If they want it to close on click outside, they need a way to kill the process.
            // But for now let's just make it work.
        }
    }

    Rectangle {
        id: mainRect
        width: 500
        height: 160
        anchors.centerIn: parent
        radius: 20
        gradient: Gradient {
             GradientStop { position: 0.0; color: "#0e141c" }
             GradientStop { position: 1.0; color: "#0f2230" }
        }
        border.color: "#223445"
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            component PowerItem : ColumnLayout {
                id: powerItemRoot
                property string label
                property string icon
                property string command
                property string color: "#6ec7ff"
                
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
                    color: mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "#1a2533"
                    border.color: mouseArea.containsMouse ? color : "#223445"
                    border.width: 1
                    Layout.alignment: Qt.AlignHCenter

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 32
                        color: mouseArea.containsMouse ? color : "#e3edff"
                        
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
                    color: mouseArea.containsMouse ? "#ffffff" : "#8ca0b8"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            PowerItem {
                label: "Shutdown"
                icon: ""
                command: "systemctl poweroff"
                color: "#ff6b6b"
            }

            PowerItem {
                label: "Reboot"
                icon: ""
                command: "systemctl reboot"
                color: "#ffb86c"
            }

            PowerItem {
                label: "Logout"
                icon: ""
                command: "/home/lucas/.config/eww/scripts/session_exit"
                color: "#bd93f9"
            }

            PowerItem {
                label: "Suspend"
                icon: "󰤄"
                command: "systemctl suspend"
                color: "#50fa7b"
            }
        }
    }
}
