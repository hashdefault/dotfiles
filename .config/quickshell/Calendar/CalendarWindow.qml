import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

PanelWindow {
    id: root

    anchors {
        top: true
        right: true
    }
    margins {
        top: 10
        right: 10
    }
    width: 280
    height: 270
    color: "transparent"

    property int displayedMonth: new Date().getMonth()
    property int displayedYear: new Date().getFullYear()

    function showPreviousMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear -= 1
        } else {
            displayedMonth -= 1
        }
    }

    function showNextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear += 1
        } else {
            displayedMonth += 1
        }
    }

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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 28
                    radius: 8
                    color: previousMonthArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.02)
                    border.color: previousMonthArea.containsMouse ? theme.accent : theme.borderDim
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "<"
                        color: previousMonthArea.containsMouse ? theme.accent : theme.textMuted
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    MouseArea {
                        id: previousMonthArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.showPreviousMonth()
                    }
                }

                Text {
                    text: Qt.formatDateTime(new Date(root.displayedYear, root.displayedMonth, 1), "MMMM yyyy")
                    color: theme.text
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 16
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 28
                    radius: 8
                    color: nextMonthArea.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(255, 255, 255, 0.02)
                    border.color: nextMonthArea.containsMouse ? theme.accent : theme.borderDim
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: ">"
                        color: nextMonthArea.containsMouse ? theme.accent : theme.textMuted
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 15
                        font.bold: true
                    }

                    MouseArea {
                        id: nextMonthArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.showNextMonth()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(255, 255, 255, 0.02)
                border.color: theme.border
                border.width: 1
                radius: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    DayOfWeekRow {
                        Layout.fillWidth: true
                        locale: calendarGrid.locale
                        font.family: "Ubuntu Nerd Font"

                        delegate: Text {
                            text: model.shortName
                            color: theme.textMuted
                            font.family: "Ubuntu Nerd Font"
                            font.pixelSize: 12
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MonthGrid {
                        id: calendarGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        month: root.displayedMonth
                        year: root.displayedYear

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
}
