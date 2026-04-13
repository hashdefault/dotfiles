import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

PanelWindow {
    anchors {
        top: true
        right: true
    }
    margins {
        top: 10
        right: 10
    }
    width: 280
    height: 250
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
             GradientStop { position: 0.45; color: theme.gradientMid }
             GradientStop { position: 1.0; color: theme.gradientBottom }
        }
        border.color: theme.borderDim
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                id: dateLabel
                text: Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                color: theme.text
                font.family: "Ubuntu Nerd Font"
                font.pixelSize: 16
                font.bold: true
                Layout.alignment: Qt.AlignHCenter

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateLabel.text = Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(255, 255, 255, 0.02)
                border.color: theme.border
                border.width: 1
                radius: 10

                MonthGrid {
                    id: calendarGrid
                    anchors.fill: parent
                    anchors.margins: 6
                    month: new Date().getMonth()
                    year: new Date().getFullYear()

                    font.family: "Ubuntu Nerd Font"

                    delegate: Rectangle {
                        readonly property bool isCurrentMonth: model.month === calendarGrid.month
                        color: model.today ? Qt.rgba(theme.accentR/255, theme.accentG/255, theme.accentB/255, 0.15) : "transparent"
                        radius: 8
                        opacity: isCurrentMonth ? 1.0 : 0.3

                        Text {
                            anchors.centerIn: parent
                            text: model.day
                            color: model.today ? theme.accent : theme.text
                            font.family: "Ubuntu Nerd Font"
                            font.bold: model.today
                        }
                    }
                }
            }
        }
    }
}
