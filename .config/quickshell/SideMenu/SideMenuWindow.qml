import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../theme.js" as Theme

PanelWindow {
    anchors {
        top: true
        left: true
    }
    margins {
        top: 10
        left: 10
    }
    implicitWidth: 420
    implicitHeight: 680
    color: "transparent"

    Component.onCompleted: {
        // Removed requestActivate()
    }

    Connections {
        target: Qt.application
        function onStateChanged() {
            // Removed Qt.quit()
        }
    }

    // --- State Properties ---
    property bool nightlightActive: false
    property bool wifiActive: false
    property bool bluetoothActive: false
    property bool dndActive: false

    property string greeterText: "Hello"
    property string username: "User"
    property string quoteText: "Loading quote..."

    // --- Polling Timers/Processes ---

    // Nightlight
    Timer {
        running: true; repeat: true; interval: 1000
        onTriggered: nightlightProc.running = true
    }
    Process {
        id: nightlightProc
        command: ["/home/lucas/.config/eww/scripts/nightlight_status"]
        stdout: SplitParser { onRead: data => nightlightActive = (data.trim() === "true") }
    }

    // Wifi
    Timer {
        running: true; repeat: true; interval: 2000
        onTriggered: wifiProc.running = true
    }
    Process {
        id: wifiProc
        command: ["/home/lucas/.config/eww/scripts/wifi", "--is-on"]
        stdout: SplitParser { onRead: data => wifiActive = (data.trim() === "true") }
    }

    // Bluetooth
    Timer {
        running: true; repeat: true; interval: 2000
        onTriggered: bluetoothProc.running = true
    }
    Process {
        id: bluetoothProc
        command: ["/home/lucas/.config/eww/scripts/getbluetooth"]
        stdout: SplitParser { onRead: data => bluetoothActive = (data.trim() === "on") } // Check what getbluetooth returns
    }

    // DND
    Timer {
        running: true; repeat: true; interval: 2000
        onTriggered: dndProc.running = true
    }
    Process {
        id: dndProc
        command: ["dunstctl", "is-paused"]
        stdout: SplitParser { onRead: data => dndActive = (data.trim() === "true") }
    }

    // Greeter
    Timer {
        running: true; repeat: true; interval: 600000
        triggeredOnStart: true
        onTriggered: greeterProc.running = true
    }
    Process {
        id: greeterProc
        command: ["/home/lucas/.config/eww/scripts/greeter"]
        stdout: SplitParser { onRead: data => greeterText = data.trim() }
    }

    // User
    Timer {
        running: true; repeat: true; interval: 60000
        triggeredOnStart: true
        onTriggered: userProc.running = true
    }
    Process {
        id: userProc
        command: ["whoami"]
        stdout: SplitParser { onRead: data => username = data.trim() }
    }

    // Quote
    Timer {
        running: true; repeat: true; interval: 1800000
        triggeredOnStart: true
        onTriggered: quoteProc.running = true
    }
    Process {
        id: quoteProc
        command: ["/home/lucas/.config/eww/scripts/getquote"]
        stdout: SplitParser { onRead: data => quoteText = data.trim() }
    }

    Rectangle {
        id: mainRect
        anchors.fill: parent
        anchors.rightMargin: 4
        anchors.bottomMargin: 4
        radius: 20
        gradient: Gradient {
             GradientStop { position: 0.0; color: Theme.gradientTop }
             GradientStop { position: 1.0; color: Theme.gradientBottom }
        }
        border.color: Theme.border
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 25
            spacing: 24

            // --- Header / Profile ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                Rectangle {
                    width: 80; height: 80
                    radius: 40
                    color: "transparent"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "file:///home/lucas/.local/share/images/avatar.png"
                        fillMode: Image.PreserveAspectCrop

                        onStatusChanged: if (status == Image.Error) source = "https://ui-avatars.com/api/?name=" + username + "&background=6ec7ff&color=0c1826"
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: Theme.accent
                        border.width: 2
                        radius: 40
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true

                    Text {
                        text: greeterText
                        color: Theme.textMuted
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 16
                    }
                    Text {
                        text: username.charAt(0).toUpperCase() + username.slice(1)
                        color: "#ffffff"
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 26
                        font.bold: true
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignRight
                    Text {
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        color: Theme.accent
                        font.family: "Hack"
                        font.pixelSize: 28
                        font.bold: true

                        Timer {
                            interval: 60000; running: true; repeat: true
                            onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm")
                        }
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "MMM d, yyyy")
                        color: Theme.textMuted
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#ffffff"
                opacity: 0.1
            }

            // --- Quick Controls Grid ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Quick Controls"
                    color: Theme.accent
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 12
                    Layout.fillWidth: true

                    component ModernToggle : Rectangle {
                        id: toggleRoot
                        property string label
                        property string icon
                        property bool active
                        property string command

                        Layout.fillWidth: true
                        height: 60
                        radius: 12
                        color: active ? Qt.rgba(Theme.accentR/255, Theme.accentG/255, Theme.accentB/255, 0.15) : Theme.cardBg
                        border.color: active ? Theme.accent : Theme.border
                        border.width: 1

                        Process {
                            id: toggleProc
                            command: ["sh", "-c", toggleRoot.command]
                            running: false
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 15
                            anchors.rightMargin: 15
                            spacing: 12

                            Rectangle {
                                width: 36; height: 36
                                radius: 18
                                color: active ? Theme.accent : Theme.border

                                Text {
                                    anchors.centerIn: parent
                                    text: icon
                                    font.family: "Ubuntu Nerd Font"
                                    font.pixelSize: 18
                                    color: active ? Theme.darkBase : Theme.textMuted
                                }
                            }

                            Text {
                                text: label
                                color: active ? "#ffffff" : Theme.text
                                font.family: "Ubuntu Nerd Font"
                                font.pixelSize: 14
                                font.bold: true
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toggleProc.running = true
                            }
                        }
                    }

                    ModernToggle {
                        label: "Night Light"
                        icon: nightlightActive ? "󰛨" : "󰹏"
                        active: nightlightActive
                        command: "/home/lucas/.config/eww/scripts/nightlight --toggle"
                    }

                    ModernToggle {
                        label: "Wi-Fi"
                        icon: wifiActive ? "󰖩" : "󰖪"
                        active: wifiActive
                        command: "/home/lucas/.config/eww/scripts/wifi --toggle"
                    }

                    ModernToggle {
                        label: "Bluetooth"
                        icon: bluetoothActive ? "󰂯" : "󰂲"
                        active: bluetoothActive
                        command: "/home/lucas/.config/eww/scripts/bluetooth --toggle"
                    }

                    ModernToggle {
                        label: "DnD Mode"
                        icon: dndActive ? "󰂛" : "󰂚"
                        active: dndActive
                        command: "dunstctl set-paused toggle"
                    }
                }
            }

            // --- Quote Card ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 16
                color: Theme.cardBg
                border.color: Theme.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 8

                    Text {
                        text: "󱆧"
                        color: Theme.accent
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 20
                        opacity: 0.5
                    }

                    Text {
                        text: quoteText
                        color: Theme.text
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 14
                        font.italic: true
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }
                }
            }

            // --- Power Menu ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                component ModernPowerBtn : Rectangle {
                    id: powerBtnRoot
                    property string icon
                    property string command
                    property string bgColor

                    Layout.fillWidth: true
                    height: 54
                    radius: 12
                    color: Theme.cardBg
                    border.color: Theme.border
                    border.width: 1

                    Process {
                        id: proc
                        command: ["sh", "-c", powerBtnRoot.command]
                        running: false
                    }

                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 22
                        color: Theme.text
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.border.color = Theme.accent
                        onExited: parent.border.color = Theme.border
                        onClicked: {
                            proc.running = true
                        }
                    }
                }

                ModernPowerBtn { icon: "󰐥"; command: "systemctl poweroff" }
                ModernPowerBtn { icon: "󰜉"; command: "systemctl reboot" }
                ModernPowerBtn { icon: "󰍃"; command: "/home/lucas/.config/eww/scripts/session_exit" }
                ModernPowerBtn { icon: "󰤄"; command: "systemctl suspend" }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
