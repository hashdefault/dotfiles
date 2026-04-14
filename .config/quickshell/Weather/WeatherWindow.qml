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
    implicitWidth: 500
    implicitHeight: 380
    color: "transparent"

    Theme { id: theme }

    function getWMOIcon(code) {
        // WMO Weather interpretation codes (WW)
        // https://open-meteo.com/en/docs
        if (code === 0) return "󰖙" // Clear sky
        if (code >= 1 && code <= 3) return "󰖐" // Mainly clear, partly cloudy, and overcast
        if (code === 45 || code === 48) return "󰖑" // Fog
        if (code >= 51 && code <= 55) return "󰖗" // Drizzle
        if (code >= 61 && code <= 65) return "󰖗" // Rain
        if (code >= 71 && code <= 75) return "󰼶" // Snow fall
        if (code >= 80 && code <= 82) return "󰖗" // Rain showers
        if (code >= 95 && code <= 99) return "󰖓" // Thunderstorm
        return "󰖐"
    }

    function getWMODesc(code) {
        if (code === 0) return "Clear sky"
        if (code === 1) return "Mainly clear"
        if (code === 2) return "Partly cloudy"
        if (code === 3) return "Overcast"
        if (code === 45 || code === 48) return "Fog"
        if (code >= 51 && code <= 55) return "Drizzle"
        if (code >= 61 && code <= 65) return "Rain"
        if (code >= 71 && code <= 75) return "Snow"
        if (code >= 80 && code <= 82) return "Showers"
        if (code >= 95 && code <= 99) return "Thunderstorm"
        return "Unknown"
    }

    function getDayName(dateStr) {
        var date = new Date(dateStr + "T00:00:00")
        var now = new Date()
        now.setHours(0,0,0,0)

        if (date.getTime() === now.getTime()) return "Today"

        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[date.getDay()]
    }

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
             GradientStop { position: 0.0; color: theme.gradientTop }
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰖐"
                    color: theme.accent
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 20
                    Layout.alignment: Qt.AlignVCenter
                }
                Text {
                    text: "Weather Forecast"
                    color: "#ffffff"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                Text {
                    id: locText
                    text: "Maringá, PR"
                    color: theme.textMuted
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#ffffff"
                opacity: 0.1
            }

            // Current Weather
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                spacing: 20

                Text {
                    id: weatherIcon
                    text: "󰖐"
                    color: theme.yellow
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 64
                    Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                    spacing: -2
                    Layout.alignment: Qt.AlignVCenter
                    Text {
                        id: tempText
                        text: "--°C"
                        color: "#ffffff"
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 42
                        font.bold: true
                    }
                    Text {
                        id: condText
                        text: "Loading..."
                        color: theme.accent
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 16
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#ffffff"
                opacity: 0.1
            }

            ListModel {
                id: forecastModel
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: forecastModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 110
                        color: index % 2 == 0 ? "#0affffff" : "#12ffffff"
                        radius: 8

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: model.day
                                color: theme.textMuted
                                font.family: "Ubuntu Nerd Font"
                                font.pixelSize: 12
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: model.icon
                                color: theme.accent
                                font.family: "Ubuntu Nerd Font"
                                font.pixelSize: 28
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: model.temp
                                color: "#ffffff"
                                font.family: "Ubuntu Nerd Font"
                                font.pixelSize: 13
                                font.bold: true
                                Layout.alignment: Qt.AlignHCenter
                            }

                            RowLayout {
                                spacing: 2
                                Layout.alignment: Qt.AlignHCenter

                                Text {
                                    text: "󰖗"
                                    color: theme.accent
                                    font.family: "Ubuntu Nerd Font"
                                    font.pixelSize: 10
                                    opacity: model.chanceOfRain > 0 ? 1 : 0.3
                                }
                                Text {
                                    text: (model.chanceOfRain || 0) + "%"
                                    color: theme.textMuted
                                    font.family: "Ubuntu Nerd Font"
                                    font.pixelSize: 10
                                    opacity: model.chanceOfRain > 0 ? 1 : 0.5
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    Process {
        id: weatherProc
        command: ["curl", "-s", "https://api.open-meteo.com/v1/forecast?latitude=-23.42&longitude=-51.92&current_weather=true&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto"]
        running: true

        property string fullData: ""

        stdout: SplitParser {
            onRead: function(data) {
                weatherProc.fullData += data
            }
        }

        onExited: (exitCode) => {
            if (exitCode === 0 && fullData.length > 0) {
                try {
                    var json = JSON.parse(fullData)
                    var current = json.current_weather

                    tempText.text = Math.round(current.temperature) + "°C"
                    condText.text = getWMODesc(current.weathercode)
                    weatherIcon.text = getWMOIcon(current.weathercode)

                    locText.text = "Maringá, PR"

                    // Update forecast
                    forecastModel.clear()
                    if (json.daily) {
                        for (var i = 0; i < 5; i++) { // Next 5 days
                            forecastModel.append({
                                "day": getDayName(json.daily.time[i]),
                                "icon": getWMOIcon(json.daily.weathercode[i]),
                                "temp": Math.round(json.daily.temperature_2m_min[i]) + "°/" + Math.round(json.daily.temperature_2m_max[i]) + "°",
                                "chanceOfRain": json.daily.precipitation_probability_max[i]
                            })
                        }
                    }

                } catch (e) {
                    condText.text = "Error parsing data"
                    locText.text = "Check internet/api"
                }
            } else if (exitCode !== 0) {
                condText.text = "Curl failed (" + exitCode + ")"
                locText.text = "Check internet connection"
            } else {
                condText.text = "No data received"
                locText.text = "Check internet connection"
            }

            // Reset buffer for next run
            fullData = ""
        }
    }

    Timer {
        interval: 900000 // Refresh every 15 mins (15 * 60 * 1000 ms)
        running: true
        repeat: true
        onTriggered: weatherProc.running = true
    }
}
