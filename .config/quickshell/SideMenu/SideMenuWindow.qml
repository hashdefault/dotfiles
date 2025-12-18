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
    width: 400
    height: 600 // Increased to accommodate content better
    color: "transparent"

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
             GradientStop { position: 0.0; color: "#0e141c" }
             GradientStop { position: 0.45; color: "#161c24" }
             GradientStop { position: 1.0; color: "#0f2230" }
        }
        border.color: "#1f2c3a"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // --- Greeter ---
            ColumnLayout {
                spacing: 5
                Layout.alignment: Qt.AlignHCenter
                Text {
                    text: greeterText
                    color: "#d7e6ff"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 28
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: username
                    color: "#bee6e6"
                    font.family: "Ubuntu Nerd Font"
                    font.pixelSize: 32
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            // --- Profile ---
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: parent.width * 0.95
                Layout.preferredHeight: 130
                color: Qt.rgba(255, 255, 255, 0.02)
                border.color: "#223445"
                border.width: 1
                radius: 14

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20

                    Image {
                        source: "file:///home/lucas/.local/share/images/avatar.png"
                        sourceSize.width: 100
                        sourceSize.height: 100
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100
                        fillMode: Image.PreserveAspectCrop
                        
                        // Border
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: "#6ec7ff"
                            border.width: 2
                            radius: 50
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true
                        
                        Text {
                            text: Qt.formatDateTime(new Date(), "HH:mm")
                            color: "#6ec7ff"
                            font.family: "Hack"
                            font.pixelSize: 42
                            font.bold: true
                            
                            Timer {
                                interval: 1000; running: true; repeat: true
                                onTriggered: parent.text = Qt.formatDateTime(new Date(), "HH:mm")
                            }
                        }
                        Text {
                            text: Qt.formatDateTime(new Date(), "dddd, MMM d")
                            color: "#d7e6ff"
                            font.family: "Hack"
                            font.pixelSize: 18
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // --- Quote ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: quoteText
                    color: "#bee6e6"
                    font.family: "Serif"
                    font.italic: true
                    font.pixelSize: 18
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.maximumWidth: parent.width * 0.9
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: parent.width * 0.6
                    height: 1
                    color: Qt.rgba(190/255, 230/255, 230/255, 0.4)
                }
            }

            // --- Toggles ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12
                
                // Helper Component for Split Button
                component ToggleItem : ColumnLayout {
                    property string label
                    property string icon
                    property bool active
                    property string command
                    
                    spacing: 8

                    Process {
                        id: toggleProc
                        command: ["sh", "-c", parent.command]
                        running: false
                    }
                    
                    // Single Button
                    Rectangle {
                        width: 75; height: 45
                        color: active ? "#6fc4ff" : Qt.rgba(255,255,255,0.04)
                        border.color: active ? "#6fc4ff" : "#223445"
                        radius: 20
                        
                        Text {
                            anchors.centerIn: parent
                            text: icon
                            font.family: "Ubuntu Nerd Font"
                            font.pixelSize: 20
                            color: active ? "#0c1826" : "#d7e6ff"
                        }
                        
                        TapHandler {
                            onTapped: {
                                toggleProc.running = false
                                toggleProc.running = true
                            }
                        }
                    }
                    
                    Text {
                        text: label
                        color: "#d7e6ff"
                        font.pixelSize: 13
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                ToggleItem {
                    label: "Night Light"
                    icon: nightlightActive ? "󰛨" : "󰹏"
                    active: nightlightActive
                    command: "/home/lucas/.config/eww/scripts/nightlight --toggle"
                }
                
                ToggleItem {
                    label: "Wifi"
                    icon: wifiActive ? "󰖩" : "󰖪"
                    active: wifiActive
                    command: "/home/lucas/.config/eww/scripts/wifi --toggle"
                }
                
                ToggleItem {
                    label: "Bluetooth"
                    icon: bluetoothActive ? "󰂯" : "󰂲"
                    active: bluetoothActive
                    command: "/home/lucas/.config/eww/scripts/getbluetooth"
                }
                
                ToggleItem {
                    label: "DnD"
                    icon: dndActive ? "󰂛" : "󰂚"
                    active: dndActive
                    command: "/home/lucas/.config/eww/scripts/do_not_disturb.sh"
                }
            }
            
            // --- Power Menu ---
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                component PowerBtn : Rectangle {
                    property string icon
                    property string command
                    property string tooltipText
                    
                    width: 50; height: 50
                    radius: 16
                    color: Qt.rgba(255,255,255,0.04)
                    border.color: "#223445"
                    border.width: 1

                    Process {
                        id: proc
                        command: ["sh", "-c", parent.command]
                        running: false
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: icon
                        font.family: "Ubuntu Nerd Font"
                        font.pixelSize: 22
                        color: "#e3edff"
                    }
                    
                    TapHandler {
                        onTapped: {
                            proc.running = false
                            proc.running = true
                        }
                    }
                }
                
                PowerBtn { icon: ""; command: "systemctl poweroff"; tooltipText: "Shutdown" }
                PowerBtn { icon: ""; command: "systemctl reboot"; tooltipText: "Reboot" }
                PowerBtn { icon: ""; command: "/home/lucas/.config/eww/scripts/session_exit"; tooltipText: "Logout" }
                PowerBtn { icon: "󰤄"; command: "systemctl suspend"; tooltipText: "Suspend" }
            }
            
            Item { Layout.fillHeight: true }
        
        }
    }
}
