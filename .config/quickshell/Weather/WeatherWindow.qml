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
        right: 300
    }
    width: 240 // Adjusted width
    height: 220 // Adjusted height
    color: "transparent"

    Component.onCompleted: {
        // Removed requestActivate() to prevent stealing focus
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            // Removed Qt.quit() on ApplicationInactive to keep widget active
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
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                Text {
                    text: "" // Weather icon for header
                    color: "#6ec7ff"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignVCenter
                }
                Text {
                    text: "Weather"
                    color: "#d7e6ff"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 18
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#223445"
            }
            
            Item { Layout.fillHeight: true } // Flexible space

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 15
                
                // Icon (using Nerd Font weather icons based on condition)
                Text {
                    id: weatherIcon
                    text: "󰖐" // Default cloud
                    color: "#f1c40f"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 48 // Slightly larger icon
                }
                
                ColumnLayout {
                    spacing: 0
                    Text {
                        id: tempText
                        text: "--°C"
                        color: "#ffffff"
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 32 // Slightly larger temperature
                        font.bold: true
                    }
                    Text {
                        id: condText
                        text: "Loading..."
                        color: "#8ca0b8"
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 14 // Slightly larger condition text
                    }
                }
            }
            
            Text {
                id: locText
                text: "Fetching Location..."
                color: "#556677"
                font.family: "Ubuntu Nerd Font"
                font.pixelSize: 10
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 5
            }
            
            Item { Layout.fillHeight: true } // Flexible space
        }
    }

    Process {
        id: weatherProc
        command: ["curl", "-s", "wttr.in/?format=j1"]
        running: true
        stdout: SplitParser {
            property var buffer: [] // Use an array to buffer all lines
            onRead: function(data) {
                buffer.push(data)
            }
            onReadFinished: function() { // This signal fires when all lines are read
                var fullData = buffer.join("") // Join all buffered lines
                buffer = [] // Clear buffer for next run
                
                if (fullData.length > 0) {
                    try {
                        var json = JSON.parse(fullData)
                        var current = json.current_condition[0]
                        var temp = current.temp_C
                        var desc = current.weatherDesc[0].value
                        
                        var icon = "󰖐" // Default cloud
                        var d = desc.toLowerCase()
                        if (d.includes("sunny") || d.includes("clear")) icon = "󰖙"
                        else if (d.includes("rain") || d.includes("drizzle")) icon = "󰖗"
                        else if (d.includes("snow") || d.includes("sleet")) icon = "󰼶"
                        else if (d.includes("thunder")) icon = "󰖓"
                        else if (d.includes("fog") || d.includes("mist")) icon = "󰖑"
                        else if (d.includes("cloud") || d.includes("overcast")) icon = "󰖐"
                        else if (d.includes("ice")) icon = " chilling" // More icons if needed

                        tempText.text = temp + "°C"
                        condText.text = desc
                        weatherIcon.text = icon
                        
                        if (json.nearest_area && json.nearest_area[0]) {
                            locText.text = json.nearest_area[0].areaName[0].value + ", " + json.nearest_area[0].country[0].value
                        } else {
                            locText.text = "Location Unknown"
                        }

                    } catch (e) {
                        condText.text = "Error parsing data"
                        locText.text = "Check internet/wttr.in"
                    }
                } else {
                    condText.text = "No data received"
                    locText.text = "Check internet connection"
                }
            }
        }
        onExited: {
            if (exitCode !== 0) {
                condText.text = "Curl failed (" + exitCode + ")"
                locText.text = "Check internet connection"
            }
            // fullBuffer is no longer used, buffer in SplitParser handles accumulation
        }
    }
    
    Timer {
        interval: 900000 // Refresh every 15 mins (15 * 60 * 1000 ms)
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }
}
