import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

PanelWindow {
    anchors { top: true; right: true }
    margins { top: 10; right: 450 }
    width: 400
    height: 350
    color: "transparent"

    Theme { id: theme }

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

    property string artist: "Artist"
    property string title: "Title"
    property string album: "Album"
    property string artUrl: ""
    property string artSource: ""
    property string status: "Stopped"
    property double duration: 1
    property double position: 0

    Timer { running: true; repeat: true; interval: 1000; onTriggered: metadataProc.running = true }
    Process {
        id: metadataProc
        command: ["playerctl", "metadata", "--format", "{{artist}}#|#{{title}}#|#{{album}}#|#{{mpris:artUrl}}#|#{{mpris:length}}#|#{{position}}"]
        stdout: SplitParser {
            onRead: data => {
                 var parts = data.trim().split("#|#");
                 if(parts.length >= 2) {
                     artist = parts[0] || "Unknown";
                     title = parts[1] || "Unknown";
                     album = parts[2] || "";
                     var rawUrl = parts[3] || "";
                     if (rawUrl) {
                         if (rawUrl.startsWith("file://")) {
                             artSource = rawUrl;
                         } else if (rawUrl.startsWith("http://") || rawUrl.startsWith("https://")) {
                             artSource = rawUrl;
                         } else {
                             artSource = "file://" + rawUrl;
                         }
                     } else {
                         artSource = "";
                     }
                     if(parts[4]) duration = parseFloat(parts[4]) / 1000000;
                     if(parts[5]) {
                         position = parseFloat(parts[5]) / 1000000;
                         if (!progressSlider.pressed) progressSlider.value = position;
                     }
                 }
            }
        }
    }

    Timer { running: true; repeat: true; interval: 1000; onTriggered: statusProc.running = true }
    Process {
        id: statusProc
        command: ["playerctl", "status"]
        stdout: SplitParser { onRead: data => status = data.trim() }
    }

    Process {
        id: seekProc
        command: ["playerctl", "position", seekPos]
        property double seekPos: 0
        running: false
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
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.borderDim
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width * 0.9
            spacing: 15

            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 130; height: 130

                Image {
                    id: coverArt
                    anchors.fill: parent
                    anchors.margins: 2
                    source: artSource
                    sourceSize.width: 130
                    sourceSize.height: 130
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    visible: false
                }

                OpacityMask {
                    anchors.fill: coverArt
                    source: coverArt
                    maskSource: Rectangle {
                        width: coverArt.width
                        height: coverArt.height
                        radius: width / 2
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: theme.accent
                    border.width: 2
                }
            }

            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Text { text: artist; color: theme.accent; font.bold: true; font.pixelSize: 16; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.maximumWidth: 300 }
                Text { text: title; color: theme.text; font.pixelSize: 14; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.maximumWidth: 300 }
                Text { text: album; color: theme.cyan; font.italic: true; font.pixelSize: 12; Layout.alignment: Qt.AlignHCenter; elide: Text.ElideRight; Layout.maximumWidth: 300 }
            }

            Slider {
                id: progressSlider
                from: 0
                to: duration > 0 ? duration : 1
                Layout.fillWidth: true

                Binding on value {
                    when: !progressSlider.pressed
                    value: position
                }

                onMoved: {
                    seekProc.seekPos = value;
                    seekProc.running = true;
                }
            }
        }
    }
}
