import QtQuick 2.0
import QtQuick.Particles 2.0

import Neuronify 1.0

import ".."
import "../controls"
import "../hud"
import "../style"

Edge {
    id: root

    property real timeStep

    objectName: "CompartmentConnection"
    filename: "edges/CompartmentConnection.qml"
    name: "Compartment connection"

    color: "purple"

    engine: EdgeEngine {
        id: engine

        property real axialResistance: 0.5 * 1e12
        property real length: 1.0 * 1e-6
        property real diameter: 0.8 * 1e-6

        onResettedDynamics: {
            currentOutput = 0
        }

        onResettedProperties: {
        }

        onStepped:{
            var Va = itemA.engine.voltage
            var Vb = itemB.engine.voltage
            var d = diameter
            var Ra = axialResistance
            var l = length
            currentOutput = - d / (4 * Ra * l * l) * (Vb - Va)
            currentInput = -currentOutput
        }
    }

    savedProperties: [
        PropertyGroup {
            property alias engine: engine
        }
    ]

    controls: Component {
        PropertiesPage {
            BoundSlider {
                target: engine
                property: "maximumCurrent"
                text: "Maximum current"
                unit: "nA"
                minimumValue: 0e-9
                maximumValue: 10e-9
                unitScale: 1e-9
                stepSize: 0.1e-9
                precision: 1
            }
            BoundSlider {
                target: engine
                property: "tau"
                text: "Time constant"
                unit: "ms"
                minimumValue: 0.1e-3
                maximumValue: 6.0e-3
                unitScale: 1e-3
                stepSize: 1e-4
                precision: 2
            }
            BoundSlider {
                target: engine
                property: "delay"
                text: "Delay"
                unit: "ms"
                minimumValue: 0.0e-3
                maximumValue: 30.0e-3
                unitScale: 1e-3
                stepSize: 1e-4
                precision: 1
            }
        }
    }

    Component {
        id: signalComponent
        Rectangle {
            id: signalRectangle
            property real delay: 0.0
            property real fraction: 0.0
            property real previousTime: Date.now()

            width: 24
            height: width
            radius: width * 0.5
//            source: "qrc:///images/particles/particle.png"
            color: root.itemA ? root.itemA.color : "black"

            x: root.startPoint.x + (root.endPoint.x - root.startPoint.x) * fraction - width / 2
            y: root.startPoint.y + (root.endPoint.y - root.startPoint.y) * fraction - height / 2

            opacity: Math.min(1.0, 3 * (1.0 - fraction))

            Connections {
                target: engine
                onStepped: {
                    var duration = Math.max(240, delay / (root.timeStep * root.playbackSpeed) * 16)
                    var currentTime = Date.now()
                    var delta = currentTime - previousTime
                    signalRectangle.fraction += delta / duration
                    previousTime = currentTime
                    if(fraction > 1.0) {
                        signalRectangle.destroy()
                    }
                }
            }
        }
    }
}
