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
    implicitWidth: 320
    implicitHeight: 280
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

            // Header
            Text {
                text: "Opencode-go Usage"
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

            // ===== 5h Rolling Section =====
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Text { text: "  Rolling"; color: theme.textMuted; font.pixelSize: 13; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: rollingData.percentage + "%"; color: theme.text; font.pixelSize: 13; font.bold: true }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: theme.borderDim
                    Rectangle {
                        width: parent.width * (rollingData.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: rollingData.percentage > 80 ? theme.red : theme.accent
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Reset in:"; color: theme.textDim; font.pixelSize: 11; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: rollingData.reset; color: theme.orange; font.pixelSize: 11; font.bold: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.borderDim
            }

            // ===== Weekly Section =====
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Text { text: "  Weekly"; color: theme.textMuted; font.pixelSize: 13; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: weeklyData.percentage + "%"; color: theme.text; font.pixelSize: 13; font.bold: true }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: theme.borderDim
                    Rectangle {
                        width: parent.width * (weeklyData.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: weeklyData.percentage > 80 ? theme.red : theme.purple
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Reset in:"; color: theme.textDim; font.pixelSize: 11; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: weeklyData.reset; color: theme.orange; font.pixelSize: 11; font.bold: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.borderDim
            }

            // ===== Monthly Section =====
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Text { text: "  Monthly"; color: theme.textMuted; font.pixelSize: 13; font.bold: true; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: monthlyData.percentage + "%"; color: theme.text; font.pixelSize: 13; font.bold: true }
                }

                // Progress bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: theme.borderDim
                    Rectangle {
                        width: parent.width * (monthlyData.percentage / 100)
                        height: parent.height
                        radius: 4
                        color: monthlyData.percentage > 80 ? theme.red : theme.cyan
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Reset in:"; color: theme.textDim; font.pixelSize: 11; font.family: "Ubuntu Nerd Font" }
                    Item { Layout.fillWidth: true }
                    Text { text: monthlyData.reset; color: theme.orange; font.pixelSize: 11; font.bold: true }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    // ===== Data Properties =====
    QtObject {
        id: rollingData
        property real cost: 0
        property int sessions: 0
        property string input: "0"
        property string output: "0"
        property string reasoning: "0"
        property string elapsed: "0m"
        property string reset: "10h 0m"
        property int percentage: 0
    }

    QtObject {
        id: weeklyData
        property real cost: 0
        property int sessions: 0
        property string input: "0"
        property string output: "0"
        property string reasoning: "0"
        property string reset: "..."
        property int percentage: 0
    }

    QtObject {
        id: monthlyData
        property real cost: 0
        property int sessions: 0
        property string input: "0"
        property string output: "0"
        property string reasoning: "0"
        property string reset: "..."
        property int percentage: 0
    }

    property var modelsList: []
    property string lastUpdate: "..."

    // ===== Data Fetching =====
    Process {
        id: usageProc
        command: ["sh", "-c", "~/.config/waybar/modules-scripts/opencode_usage.sh --json"]
        running: true
        stdout: SplitParser {
            onRead: function(data) {
                try {
                    var json = JSON.parse(data.trim())

                    // Rolling 5h
                    rollingData.cost = json.rolling5h.cost
                    rollingData.sessions = json.rolling5h.sessions
                    rollingData.input = json.rolling5h.input
                    rollingData.output = json.rolling5h.output
                    rollingData.reasoning = json.rolling5h.reasoning
                    rollingData.elapsed = json.rolling5h.elapsed
                    rollingData.reset = json.rolling5h.reset
                    rollingData.percentage = json.rolling5h.percentage
                    modelsList = json.rolling5h.models || []

                    // Weekly
                    weeklyData.cost = json.weekly.cost
                    weeklyData.sessions = json.weekly.sessions
                    weeklyData.input = json.weekly.input
                    weeklyData.output = json.weekly.output
                    weeklyData.reasoning = json.weekly.reasoning
                    weeklyData.reset = json.weekly.reset
                    weeklyData.percentage = json.weekly.percentage

                    // Monthly
                    monthlyData.cost = json.monthly.cost
                    monthlyData.sessions = json.monthly.sessions
                    monthlyData.input = json.monthly.input
                    monthlyData.output = json.monthly.output
                    monthlyData.reasoning = json.monthly.reasoning
                    monthlyData.reset = json.monthly.reset
                    monthlyData.percentage = json.monthly.percentage

                    // Update timestamp
                    var now = new Date()
                    lastUpdate = Qt.formatTime(now, "HH:mm:ss")
                } catch (e) {
                    console.log("OpencodeUsage: JSON parse error:", e)
                }
            }
        }
    }

    // Refresh every 30 seconds
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: usageProc.running = true
    }
}
