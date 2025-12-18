import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    anchors {
        top: true
        right: true
    }
    margins {
        top: 100
        right: 50
    }
    width: 400
    height: 650
    color: "transparent"

    // Removed requestActivate to prevent stealing focus on load
    // Removed Connections to prevent closing on inactivity

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
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Header
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                Text {
                    text: " "
                    color: "#6ec7ff"
                    font.pixelSize: 24
                    font.family: "Ubuntu Nerd Font"
                }
                Text {
                    text: "Keybinds"
                    color: "#d7e6ff"
                    font.bold: true
                    font.pixelSize: 24
                    font.family: "Ubuntu Nerd Font"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(110/255, 199/255, 255/255, 0.3)
            }

            // Keybinds Grid
            GridLayout {
                columns: 2
                columnSpacing: 15
                rowSpacing: 12
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                component KeyItem : RowLayout {
                    property string key
                    property string desc
                    
                    Layout.fillWidth: true
                    spacing: 10

                    // Key Chip
                    Rectangle {
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 28
                        color: Qt.rgba(255, 255, 255, 0.05)
                        border.color: "#223445"
                        border.width: 1
                        radius: 6

                        Text {
                            anchors.centerIn: parent
                            text: key
                            color: "#6ec7ff"
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Ubuntu Nerd Font"
                        }
                    }
                    
                    // Description
                    Text {
                        text: desc
                        color: "#d7e6ff"
                        font.pixelSize: 13
                        font.family: "Ubuntu Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                // Column 1
                KeyItem { key: "SUPER + SHIFT + Enter"; desc: "Terminal" }
                KeyItem { key: "SUPER + SHIFT + F"; desc: "Files" }
                KeyItem { key: "SUPER + SHIFT + V"; desc: "Clipboard" }
                KeyItem { key: "SUPER + SHIFT + N"; desc: "Edit Notes" }
                KeyItem { key: "SUPER + SHIFT + C"; desc: "Close" }
                KeyItem { key: "SUPER + SHIFT + R"; desc: "Reload" }
                KeyItem { key: "SUPER + SHIFT + Q"; desc: "Logout" }
                KeyItem { key: "SUPER + M"; desc: "Profile" }
                KeyItem { key: "SUPER + R"; desc: "Rofi" }
                
                // Note: The original list was quite long. 
                // A single column layout inside a GridLayout (essentially acting as a list) might be better if we want strict alignment.
                // Or we can continue the list.
                
                KeyItem { key: "SUPER + B"; desc: "Browser" }
                KeyItem { key: "SUPER + N"; desc: "Notify" }
                KeyItem { key: "SUPER + Q"; desc: "Power" }
                KeyItem { key: "SUPER + G"; desc: "Sys Mon" }
                KeyItem { key: "SUPER + V"; desc: "Volume" }
                KeyItem { key: "SUPER + H,L,K,J"; desc: "Focus" }
                KeyItem { key: "SUPER + O"; desc: "Swap" }
                KeyItem { key: "Print"; desc: "Shot" }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
