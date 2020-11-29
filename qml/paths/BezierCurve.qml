import QtQuick 2.0
import QtQuick.Shapes 1.15

Shape {
    id:canvas

    property alias color: shapePath.strokeColor
    property real lineWidth: shapePath.strokeWidth
    property point startPoint: Qt.point(0,0)
    property point controlPoint1: Qt.point(0,40)
    property point controlPoint2: Qt.point(200,100)
    property point endPoint: Qt.point(100,100)

    ShapePath {
        id: shapePath
        strokeWidth: 4
        strokeColor: "purple"
        fillColor: "transparent"
        startX: startPoint.x
        startY: startPoint.y
        PathCubic {
            id: path
            x: endPoint.x
            y: endPoint.y
            control1X: controlPoint1.x
            control1Y: controlPoint1.y
            control2X: controlPoint2.x
            control2Y: controlPoint2.y
        }
    }
}
