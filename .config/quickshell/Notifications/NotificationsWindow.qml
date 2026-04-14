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
    implicitWidth: 400
    implicitHeight: 700
    color: "transparent"

    Theme { id: theme }

    Connections {
        target: Qt.application
        function onStateChanged() {
            // Removed Qt.quit()
        }
    }

    // Model to store notifications
    ListModel {
        id: notifModel
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

            // --- Header ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Layout.alignment: Qt.AlignVCenter // Align items vertically in the middle

                Text {
                    text: " Bell" // Added a bell icon
                    color: theme.accent
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 22
                    Layout.alignment: Qt.AlignVCenter
                }
                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Text {
                        text: "Notifications"
                        color: theme.text
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 22
                        font.bold: true
                    }
                    Text {
                        text: "Recent alerts & history"
                        color: theme.textMuted
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 12
                    }
                }

                Rectangle {
                    width: 90; height: 35 // Slightly larger button
                    radius: 10 // More rounded
                    color: clearMouse.containsMouse ? theme.cardBg : Qt.rgba(255, 255, 255, 0.05)
                    border.color: theme.border
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "󰩺 Clear"
                        color: clearMouse.containsMouse ? theme.text : theme.textMuted // Color change on hover
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 13
                    }

                    HoverHandler { id: clearMouse }
                    TapHandler {
                        onTapped: clearAllProc.running = true
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
            }

            // --- List ---
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: notifModel
                spacing: 10

                // Scroll to bottom when new item added
                onCountChanged: positionViewAtEnd()

                delegate: Rectangle {
                    width: listView.width
                    height: contentCol.height + 20
                    color: Qt.rgba(255, 255, 255, 0.04)
                    radius: 12
                    border.color: theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 15

                        // Icon
                        Image {
                            source: (model.iconPath && model.iconPath !== "") ?
                                    (model.iconPath.startsWith("/") ? "file://" + model.iconPath : model.iconPath) :
                                    "file:///usr/share/icons/Adwaita/48x48/status/dialog-information.png"

                            sourceSize.width: 48
                            sourceSize.height: 48
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            fillMode: Image.PreserveAspectFit
                        }

                        // Content
                        ColumnLayout {
                            id: contentCol
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.appname
                                    color: theme.textMuted
                                    font.pixelSize: 10
                                    font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: model.timestamp
                                    color: theme.textDim
                                    font.pixelSize: 10
                                }
                            }

                            Text {
                                text: model.summary
                                color: theme.text
                                font.pixelSize: 14
                                font.bold: true
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                            }
                            Text {
                                text: model.body
                                color: theme.textMuted
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            // Screenshot Buttons
                            RowLayout {
                                visible: model.appname === "Screenshot"
                                spacing: 10
                                Layout.topMargin: 5

                                Rectangle {
                                    width: 60; height: 24
                                    radius: 4
                                    color: theme.border
                                    Text { anchors.centerIn: parent; text: "Open"; color: "white"; font.pixelSize: 10 }
                                    TapHandler {
                                        onTapped: {
                                            var cmd = "shotwell '" + model.iconPath + "' &"
                                            Qt.createQmlObject('import Quickshell; Process { command: ["sh", "-c", "' + cmd + '"]; running: true }', parent)
                                        }
                                    }
                                }
                            }
                        }

                        // Dismiss Button
                        Rectangle {
                            width: 24; height: 24
                            radius: 12
                            color: dismissHover.containsMouse ? theme.red : Qt.rgba(255, 255, 255, 0.05)
                            border.color: dismissHover.containsMouse ? theme.red : theme.border

                            Text {
                                anchors.centerIn: parent
                                text: "󰅚"
                                color: dismissHover.containsMouse ? "#1e1e1e" : theme.textMuted
                                font.family: "Ubuntu Nerd Font"
                                font.pixelSize: 12
                            }

                            HoverHandler { id: dismissHover }
                            TapHandler {
                                onTapped: {
                                    notifModel.remove(index)
                                }
                            }
                        }
                    }
                }

                Text {
                    id: noNotifText
                    anchors.centerIn: parent // Center the text if no notifications
                    text: "No notifications"
                    color: theme.textDim
                    visible: notifModel.count === 0
                    font.italic: true
                }
            }
        }
    }

    // Process to ensure dunstlog exists and is tailed correctly
    Process {
        id: ensureDunstlogProc
        command: ["sh", "-c", "touch /tmp/dunstlog"]
        onExited: (exitCode) => {
            tailProc.running = true // Start tailing after ensuring the file exists
        }
    }

    // Process to follow log
    Process {
        id: tailProc
        // tail -F is crucial for handling log rotation/truncation reliably
        command: ["tail", "-n", "50", "-F", "/tmp/dunstlog"]
        running: false // Start only after ensureDunstlogProc
        stdout: SplitParser {
            onRead: function(line) {
                if (line.trim() === "") return;

                var fields = line.split(";")
                if (fields.length < 6) return;

                var appname = fields[5]
                var summary = fields[4]
                var body = fields[3]
                var icon = fields[2]
                var urgency = fields[1]
                var ts = fields[0]

                // Add to model
                notifModel.append({
                    "timestamp": ts,
                    "urgency": urgency,
                    "iconPath": icon,
                    "body": body,
                    "summary": summary,
                    "appname": appname
                })
            }
        }
    }

    // Process for Clear All
    Process {
        id: clearAllProc
        command: ["sh", "-c", "dunstctl history-clear && : > /tmp/dunstlog"]
        onExited: (exitCode) => {
            notifModel.clear()
            // tail -F will automatically re-open the file if it's truncated or recreated,
            // so no manual restart is strictly needed but doesn't hurt.
            // However, to ensure it picks up immediately if cleared, a restart is safer.
            tailProc.running = false
            ensureDunstlogProc.running = true // Ensure file exists then restart tail
        }
    }

    Component.onCompleted: {
        ensureDunstlogProc.running = true // Run this on component load
    }
}
