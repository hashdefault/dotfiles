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
    implicitWidth: 400
    implicitHeight: 650
    color: "transparent"

    Theme { id: theme }

    WlrLayershell.layer: WlrLayershell.Background
    WlrLayershell.namespace: "quickshell-tips"

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
             GradientStop { position: 0.0; color: theme.gradientTop }
             GradientStop { position: 0.45; color: theme.gradientMid }
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.borderDim
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
                    text: " "
                    color: theme.accent
                    font.pixelSize: 24
                    font.family: "Ubuntu Nerd Font"
                }
                Text {
                    text: "Keybinds"
                    color: theme.text
                    font.bold: true
                    font.pixelSize: 24
                    font.family: "Ubuntu Nerd Font"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(theme.accentR/255, theme.accentG/255, theme.accentB/255, 0.3)
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
                    property string app: ""

                    Layout.fillWidth: true
                    spacing: 12

                    // Key Chip
                    Rectangle {
                        Layout.preferredWidth: 160
                        Layout.preferredHeight: 30
                        color: Qt.rgba(theme.accentR/255, theme.accentG/255, theme.accentB/255, 0.08)
                        border.color: theme.border
                        border.width: 1
                        radius: 8

                        Text {
                            anchors.centerIn: parent
                            text: key
                            color: theme.accent
                            font.bold: true
                            font.pixelSize: 11
                            font.family: "Ubuntu Nerd Font"
                        }
                    }

                    // Description with App
                    Text {
                        text: desc + (app !== "" ? " (" + app + ")" : "")
                        color: theme.text
                        font.pixelSize: 13
                        font.family: "Ubuntu Nerd Font"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                // Column 1
                KeyItem { key: "SUPER + SHIFT + Enter"; desc: "Terminal"; app: "Alacritty" }
                KeyItem { key: "SUPER + SHIFT + F"; desc: "Files"; app: "Thunar" }
                KeyItem { key: "SUPER + SHIFT + V"; desc: "Clipboard"; app: "CopyQ" }
                KeyItem { key: "SUPER + SHIFT + N"; desc: "Edit Notes"; app: "Neovim" }
                KeyItem { key: "SUPER + SHIFT + C"; desc: "Close Window"; app: "System" }
                KeyItem { key: "SUPER + SHIFT + R"; desc: "Reload Config"; app: "System" }
                KeyItem { key: "SUPER + SHIFT + Q"; desc: "Exit Session"; app: "Logout" }
                KeyItem { key: "SUPER + M"; desc: "Open SideMenu"; app: "Quickshell" }
                KeyItem { key: "SUPER + R"; desc: "Run Launcher"; app: "Rofi" }
                KeyItem { key: "SUPER + B"; desc: "Web Browser"; app: "Firefox" }
                KeyItem { key: "SUPER + N"; desc: "Notifications"; app: "Dunst" }
                KeyItem { key: "SUPER + Q"; desc: "Power Menu"; app: "Quickshell" }
                KeyItem { key: "SUPER + G"; desc: "System Monitor"; app: "Quickshell" }
                KeyItem { key: "SUPER + V"; desc: "Volume Control"; app: "Pavucontrol" }
                KeyItem { key: "SUPER + H,L,K,J"; desc: "Focus Window"; app: "System" }
                KeyItem { key: "SUPER + O"; desc: "Swap Window"; app: "System" }
                KeyItem { key: "Print"; desc: "Screenshot"; app: "Grim/Slurp" }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
