import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    anchors {
        top: true
        right: true
    }
    margins {
        top: 32
        right: 120
    }
    implicitWidth: 220
    implicitHeight: themeList.length * 42 + 24
    color: "transparent"

    Theme { id: theme }

    Component.onCompleted: {
        currentThemeProc.running = true
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationInactive) {
                Qt.quit()
            }
        }
    }

    property string currentTheme: ""
    property var themeList: [
        "Cyberpunk",
        "Nord",
        "Tokyo Night",
        "Everforest",
        "Rose Pine",
        "Doom One",
        "Eldritch",
        "Monokai",
        "Solarized Dark",
        "Amber"
    ]

    Process {
        id: currentThemeProc
        command: ["cat", "/home/lucas/.config/hypr/current-theme.txt"]
        stdout: SplitParser {
            onRead: data => currentTheme = data.trim()
        }
    }

    function applyTheme(name) {
        currentTheme = name
        themeApplyProc.command = ["sh", "-c",
            "echo '" + name + "' > /home/lucas/.config/hypr/current-theme.txt && " +
            "setsid /home/lucas/.config/hypr/scripts/theme-chooser.sh --apply >/dev/null 2>&1 &"
        ]
        themeApplyProc.running = true
    }

    Process {
        id: themeApplyProc
        command: ["true"]
        running: false
        onExited: Qt.quit()
    }

    // Shadow
    Rectangle {
        anchors.fill: mainRect
        anchors.leftMargin: 3
        anchors.topMargin: 3
        color: "#000000"
        opacity: 0.4
        radius: 12
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.rightMargin: 3
        anchors.bottomMargin: 3
        radius: 12
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.gradientTop }
            GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: themeList

                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 8
                    color: {
                        if (currentTheme === modelData)
                            return Qt.rgba(theme.accentR/255, theme.accentG/255, theme.accentB/255, 0.18)
                        if (hoverArea.containsMouse)
                            return Qt.rgba(255, 255, 255, 0.06)
                        return "transparent"
                    }
                    border.color: currentTheme === modelData ? theme.accent : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: modelData
                            color: currentTheme === modelData ? theme.accent : (hoverArea.containsMouse ? "#ffffff" : theme.text)
                            font.family: "Ubuntu Nerd Font"
                            font.pixelSize: 13
                            font.bold: currentTheme === modelData
                            Layout.fillWidth: true

                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        Text {
                            text: currentTheme === modelData ? "󰄬" : ""
                            color: theme.accent
                            font.family: "Ubuntu Nerd Font"
                            font.pixelSize: 16
                            visible: currentTheme === modelData
                        }
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (currentTheme !== modelData) {
                                applyTheme(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
