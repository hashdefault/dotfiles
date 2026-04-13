import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property color color: "#50fa7b"
    property color backgroundColor: "#1f2c3a"
    property real percentage: 0
    property string icon: ""
    property string label: ""
    property string valueText: ""
    property string textColor: "#ebdbb2"
    property string labelColor: "#928374"

    implicitWidth: 100
    implicitHeight: 120

    Shape {
        id: shape
        anchors.centerIn: parent
        width: 80
        height: 80
        layer.enabled: true
        layer.samples: 4

        ShapePath {
            strokeColor: root.backgroundColor
            strokeWidth: 8
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 40; centerY: 40
                radiusX: 36; radiusY: 36
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 8
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 40; centerY: 40
                radiusX: 36; radiusY: 36
                startAngle: -90
                sweepAngle: 360 * (root.percentage / 100)
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 2
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            font.family: "Ubuntu Nerd Font"
            font.pixelSize: 20
            color: root.color
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.valueText
            font.bold: true
            color: root.textColor
            font.pixelSize: 12
        }
    }

    Text {
        anchors.top: shape.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.label
        color: root.labelColor
        font.pixelSize: 12
        font.bold: true
    }
}
