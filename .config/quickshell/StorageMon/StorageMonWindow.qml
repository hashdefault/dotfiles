import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

PanelWindow {
    anchors {
        top: true
        left: true
    }
    margins {
        top: 10
        left: 10
    }
    implicitWidth: 240
    implicitHeight: 350
    color: "transparent"

    Component.onCompleted: {
        // Removed requestActivate() to prevent stealing focus
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            // Removed Qt.quit() on ApplicationInactive
        }
    }

    // Shadow
    Rectangle {
        anchors.fill: mainRect
        anchors.leftMargin: 4
        anchors.topMargin: 4
        color: "#000000"
        opacity: 0.5
        radius: 12
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.rightMargin: 4
        anchors.bottomMargin: 4
        radius: 12
        gradient: Gradient {
             GradientStop { position: 0.0; color: "#0e141c" }
             GradientStop { position: 1.0; color: "#0f2230" }
        }
        border.color: "#223445"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 12

            Text {
                text: "System Monitor"
                color: "#d7e6ff"
                font.family: "Ubuntu Nerd Font"
                font.pixelSize: 18
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#223445"
            }

            // --- CPU ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "  CPU"; color: "#8ca0b8"; font.pixelSize: 13; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: cpuUsage.percentage + "%"; color: "#d7e6ff"; font.pixelSize: 12; font.bold: true }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1f2c3a"
                    Rectangle {
                        width: parent.width * (cpuUsage.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: cpuUsage.percentage > 80 ? "#ff6b6b" : "#50fa7b"
                    }
                }
            }

            // --- RAM ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "  RAM"; color: "#8ca0b8"; font.pixelSize: 13; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: ramUsage.percentage + "%"; color: "#d7e6ff"; font.pixelSize: 12; font.bold: true }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1f2c3a"
                    Rectangle {
                        width: parent.width * (ramUsage.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: ramUsage.percentage > 80 ? "#ff6b6b" : "#ffb86c"
                    }
                }
                Text {
                    text: ramUsage.used + " used of " + ramUsage.total
                    color: "#556677"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignRight
                }
            }
            
            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#223445"
            }

            // --- Storage ---
            // Root Partition
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "  / (Root)"; color: "#8ca0b8"; font.pixelSize: 12; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: rootStorage.percentage + "%"; color: "#d7e6ff"; font.pixelSize: 12; font.bold: true }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1f2c3a"
                    Rectangle {
                        width: parent.width * (rootStorage.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: rootStorage.percentage > 80 ? "#ff6b6b" : "#6ec7ff"
                    }
                }
                Text {
                    text: rootStorage.used + " used of " + rootStorage.total
                    color: "#556677"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Home Partition
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: homeStorage.total !== ""
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "  /home"; color: "#8ca0b8"; font.pixelSize: 12; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: homeStorage.percentage + "%"; color: "#d7e6ff"; font.pixelSize: 12; font.bold: true }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1f2c3a"
                    Rectangle {
                        width: parent.width * (homeStorage.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: homeStorage.percentage > 80 ? "#ff6b6b" : "#bd93f9"
                    }
                }
                Text {
                    text: homeStorage.used + " used of " + homeStorage.total
                    color: "#556677"
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignRight
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }

    QtObject {
        id: cpuUsage
        property int percentage: 0
    }

    QtObject {
        id: ramUsage
        property string total: "..."
        property string used: "..."
        property int percentage: 0
    }

    QtObject {
        id: rootStorage
        property string total: "..."
        property string used: "..."
        property int percentage: 0
    }

    QtObject {
        id: homeStorage
        property string total: ""
        property string used: ""
        property int percentage: 0
    }

    // CPU Process
    Process {
        id: cpuProc
        // Get CPU idle time and subtract from 100
        // $8 is typically 'id' (idle) in default top output
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"] 
        
        running: true
        stdout: SplitParser { onRead: data => cpuUsage.percentage = parseInt(data.trim()) }
    }

    // RAM Process
    Process {
        id: ramProc
        command: ["sh", "-c", "free -h --si | grep Mem"]
        running: true
        stdout: SplitParser { 
            onRead: function(data) {
                // Mem: 15G 4.2G ...
                var parts = data.split(/\s+/)
                if (parts.length < 3) return
                
                ramUsage.total = parts[1] // Total
                ramUsage.used = parts[2]  // Used
                
                // Parse for percentage
                // We need raw numbers for percentage or parsing the strings. 
                // Let's run a separate simpler awk for percentage or parse the suffix in JS.
                // Simpler: get percentage directly in shell
            }
        }
    }

    // RAM Percentage Process (Cleaner separation)
    Process {
        id: ramPercentProc
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        running: true
        stdout: SplitParser { onRead: data => ramUsage.percentage = parseInt(data.trim()) }
    }

    // Storage Process
    Process {
        id: dfProc
        command: ["sh", "-c", "df -h | grep -E '$|/$|/home$'"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.split(/\s+/)
                if (parts.length < 6) return

                var size = parts[1]
                var used = parts[2]
                var percentStr = parts[4].replace("%", "")
                var mount = parts[5]

                if (mount === "/") {
                    rootStorage.total = size
                    rootStorage.used = used
                    rootStorage.percentage = parseInt(percentStr)
                } else if (mount === "/home") {
                    homeStorage.total = size
                    homeStorage.used = used
                    homeStorage.percentage = parseInt(percentStr)
                }
            }
        }
    }
    
    Timer {
        interval: 2000 // Refresh CPU/RAM every 2s
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            ramPercentProc.running = true
        }
    }
    
    Timer {
        interval: 10000 // Refresh Storage every 10s
        running: true
        repeat: true
        onTriggered: dfProc.running = true
    }
}
