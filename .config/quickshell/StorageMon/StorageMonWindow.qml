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
    implicitWidth: 260
    implicitHeight: 380
    color: "transparent"

    Theme { id: theme }

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
             GradientStop { position: 0.0; color: theme.gradientTop }
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10

            Text {
                text: "System Resources"
                color: theme.text
                font.family: "Ubuntu Nerd Font"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
            }

            // Top Row: CPU & RAM Rings
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                ColumnLayout {
                    spacing: 2
                    RingChart {
                        label: "CPU"
                        icon: ""
                        percentage: cpuUsage.percentage
                        valueText: cpuUsage.percentage + "%"
                        color: cpuUsage.percentage > 80 ? theme.red : theme.green
                    }
                    Text {
                        text: sysInfo.tasks + " tasks"
                        color: theme.textDim
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                ColumnLayout {
                    spacing: 2
                    RingChart {
                        label: "RAM"
                        icon: ""
                        percentage: ramUsage.percentage
                        valueText: ramUsage.percentage + "%"
                        color: ramUsage.percentage > 80 ? theme.red : theme.orange
                    }
                    Text {
                        text: ramUsage.used + " / " + ramUsage.total
                        color: theme.textDim
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.border
            }

            // Middle Section: Swap
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: swapUsage.total !== "0B" && swapUsage.total !== "0"
                RowLayout {
                    Text { text: "  Swap"; color: theme.textMuted; font.pixelSize: 12; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: swapUsage.percentage + "%"; color: theme.text; font.pixelSize: 12; font.bold: true }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: theme.borderDim
                    Rectangle {
                        width: parent.width * (swapUsage.percentage / 100)
                        height: parent.height
                        radius: 3
                        color: swapUsage.percentage > 80 ? theme.red : theme.yellow
                    }
                }
                Text {
                    text: swapUsage.used + " / " + swapUsage.total
                    color: theme.textDim
                    font.pixelSize: 10
                    Layout.alignment: Qt.AlignRight
                }
            }

            // Bottom Section: Storage
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Root
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    RowLayout {
                        Text { text: "  Root"; color: theme.textMuted; font.pixelSize: 12; font.bold: true; font.family: "Ubuntu Nerd Font" }
                        Item { Layout.fillWidth: true }
                        Text { text: rootStorage.percentage + "%"; color: theme.text; font.pixelSize: 12; font.bold: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: theme.borderDim
                        Rectangle {
                            width: parent.width * (rootStorage.percentage / 100)
                            height: parent.height
                            radius: 3
                            color: rootStorage.percentage > 80 ? theme.red : theme.accent
                        }
                    }
                    Text {
                        text: rootStorage.used + " / " + rootStorage.total
                        color: theme.textDim
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignRight
                    }
                }

                // Home
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: homeStorage.total !== ""
                    RowLayout {
                        Text { text: "  Home"; color: theme.textMuted; font.pixelSize: 12; font.bold: true; font.family: "Ubuntu Nerd Font" }
                        Item { Layout.fillWidth: true }
                        Text { text: homeStorage.percentage + "%"; color: theme.text; font.pixelSize: 12; font.bold: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: theme.borderDim
                        Rectangle {
                            width: parent.width * (homeStorage.percentage / 100)
                            height: parent.height
                            radius: 3
                            color: homeStorage.percentage > 80 ? theme.red : theme.purple
                        }
                    }
                    Text {
                        text: homeStorage.used + " / " + homeStorage.total
                        color: theme.textDim
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Footer: Uptime
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 5
                Text { text: " "; color: theme.textDim; font.family: "Ubuntu Nerd Font" }
                Text {
                    text: sysInfo.uptime
                    color: theme.textDim
                    font.pixelSize: 11
                    font.italic: true
                }
            }
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
        id: swapUsage
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

    QtObject {
        id: sysInfo
        property string uptime: "..."
        property string tasks: "..."
    }

    // CPU Process
    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
        running: true
        stdout: SplitParser { onRead: data => cpuUsage.percentage = parseInt(data.trim()) }
    }

    // Process Count
    Process {
        id: procCountProc
        command: ["sh", "-c", "ps -e --no-headers | wc -l"]
        running: true
        stdout: SplitParser { onRead: data => sysInfo.tasks = data.trim() }
    }

    // RAM Process
    Process {
        id: ramProc
        command: ["sh", "-c", "free -h --si | grep Mem"]
        running: true
        stdout: SplitParser {
            onRead: function(data) {
                var parts = data.split(/\s+/)
                if (parts.length < 3) return
                ramUsage.total = parts[1]
                ramUsage.used = parts[2]
            }
        }
    }

    // RAM Percentage Process
    Process {
        id: ramPercentProc
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100.0}'"]
        running: true
        stdout: SplitParser { onRead: data => ramUsage.percentage = parseInt(data.trim()) }
    }

    // Swap Process
    Process {
        id: swapProc
        command: ["sh", "-c", "free -h --si | grep Swap"]
        running: true
        stdout: SplitParser {
            onRead: function(data) {
                var parts = data.split(/\s+/)
                if (parts.length < 3) return
                swapUsage.total = parts[1]
                swapUsage.used = parts[2]
            }
        }
    }

    // Swap Percentage Process
    Process {
        id: swapPercentProc
        command: ["sh", "-c", "free | grep Swap | awk '{if ($2 > 0) print $3/$2 * 100.0; else print 0}'"]
        running: true
        stdout: SplitParser { onRead: data => swapUsage.percentage = parseInt(data.trim()) }
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

    // Uptime Process
    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        running: true
        stdout: SplitParser { onRead: data => sysInfo.uptime = data.trim() }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            ramPercentProc.running = true
            swapProc.running = true
            swapPercentProc.running = true
            procCountProc.running = true
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: dfProc.running = true
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeProc.running = true
    }
}
