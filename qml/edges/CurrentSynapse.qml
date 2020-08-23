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

    objectName: "CurrentSynapse"
    filename: "edges/CurrentSynapse.qml"
    name: "Current based synapse"

    engine: EdgeEngine {
        id: engine

        property bool alphaFunction
        property real tau
        property real maximumCurrent
        property real delay: 0.0

        property real time
        property real linear
        property real exponential

        property var triggers: []

        savedProperties: [
            PropertyGroup {
                // properties
                property alias tau: engine.tau
                property alias maximumCurrent: engine.maximumCurrent
                property alias delay: engine.delay
                property alias alphaFunction: engine.alphaFunction

                // dynamics
                property alias linear: engine.linear
                property alias exponential: engine.exponential
                property alias triggers: engine.triggers
            }
        ]

        function trigger() {
            if(alphaFunction) {
                linear = 0.0;
                exponential = Math.exp(1.0);
            } else {
                exponential = 1.0;
            }
        }

        onResettedDynamics: {
            linear = 0.0;
            exponential = 0.0;
            triggers.length = 0;
        }

        onResettedProperties: {
            tau = 2.0e-3
            maximumCurrent = 3.0e-9
            delay = 5.0e-3
            alphaFunction = false;
        }

        onStepped:{
            root.timeStep = dt;
            if(alphaFunction) {
                currentOutput = maximumCurrent * linear * exponential;
            } else {
                currentOutput = maximumCurrent * exponential;
            }
            if(alphaFunction) {
                linear = linear + dt / tau;
            }
            exponential = exponential - exponential * dt / tau;
            if(triggers.length > 0) {
                if(triggers[0] < time) {
                    trigger();
                    triggers.shift();
                }
            }
            time += dt;
        }

        onReceivedFire: {
            if(root.playbackSpeed < 4) {
                signalComponent.createObject(root, {delay: delay})
            }

            if(delay > 0.0) {
                triggers.push(time + delay);
            } else {
                trigger();
            }
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
                function onStepped() {
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
