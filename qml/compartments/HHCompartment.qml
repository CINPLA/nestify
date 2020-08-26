import QtQuick 2.0
import Neuronify 1.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1

import ".."
import "../edges"
import "../controls"

Node {
    id: root
    filename: "compartments/HHCompartment.qml"
    name: "Hodgkin-Huxley compartment"

    readonly property real voltage: engine.voltage
    readonly property real leakCurrent: leakCurrent.current
    readonly property real sodiumCurrent: sodiumCurrent.current
    readonly property real potassiumCurrent: potassiumCurrent.current

    width: 64
    height: 64
    color: "#dd5900"
    canReceiveConnections: true
    preferredEdge: CompartmentConnection {}

    engine: CompartmentEngine {
        id: engine

        savedProperties: PropertyGroup {
//            property alias currentOutput: engine.currentOutput
        }

        capacitance: 1e-6 * engine.area * 1e4

        LeakCurrent {
            id: leakCurrent
            property real conductance: 0.3e-3 * engine.area * 1e4
            resistance: (1.0 / conductance)
            voltage: engine.voltage
            restingPotential: -54.4e-3
        }

        SodiumCurrent {
            id: sodiumCurrent
            meanSodiumConductance: 120e-3 * engine.area * 1e4
            voltage: engine.voltage
        }

        PotassiumCurrent {
            id: potassiumCurrent
            meanPotassiumConductance: 36e-3 * engine.area * 1e4
            voltage: engine.voltage
        }
    }

    controls: Rectangle {
        color: Material.background
        width: 480
        height: 360

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }

            BoundSlider {
                target: engine
                property: "length"
                text: "Length"
                unit: "μm"
                minimumValue: 1.0e-6
                maximumValue: 300.0e-6
                stepSize: 1.0e-6
                unitScale: 1e-6
                precision: 1
            }
            BoundSlider {
                target: engine
                property: "radiusA"
                text: "Radius A"
                unit: "μm"
                minimumValue: 1.0e-6
                maximumValue: 300.0e-6
                stepSize: 1.0e-6
                unitScale: 1e-6
                precision: 1
            }
            BoundSlider {
                target: engine
                property: "radiusB"
                text: "Radius B"
                unit: "μm"
                minimumValue: 1.0e-6
                maximumValue: 300.0e-6
                stepSize: 1.0e-6
                unitScale: 1e-6
                precision: 1
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }


    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) / 10
        color: "#6baed6"
        border.color: selected ? "#08306b" : "#2171b5"
        border.width: selected ? 3.0 : 1.0
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2.0
        radius: Math.min(width, height) / 10
        color: "#f7fbff"
        opacity: (engine.voltage * 1e3 + 100) / (150)
    }

    Text {
        anchors.centerIn: parent
        text: (engine.voltage * 1e3).toFixed(1)
        font.pixelSize: 14
    }

    DropArea {
        id: dropArea
        anchors {
            fill: parent
            margins: -16
        }
        keys: ["connector"]
        onDropped: {
            receivedDrop(drop.source.node)
        }
    }

    Connector {
        color: "#dd5000"
        connectorColor: "#dd5000"
    }
}
