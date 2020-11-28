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

    property real minX: Math.min(startPoint.x - lineWidth / 2, endPoint.x - lineWidth / 2, controlPoint1.x - lineWidth / 2, controlPoint2.x - lineWidth / 2)
    property real minY: Math.min(startPoint.y - lineWidth / 2, endPoint.y - lineWidth / 2, controlPoint1.y - lineWidth / 2, controlPoint2.y - lineWidth / 2)

    property real maxX: Math.max(startPoint.x, endPoint.x, controlPoint1.x, controlPoint2.x)
    property real maxY: Math.max(startPoint.y, endPoint.y, controlPoint1.y, controlPoint2.y)

    ShapePath {
        id: shapePath
        strokeWidth: 4
        strokeColor: "purple"
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
