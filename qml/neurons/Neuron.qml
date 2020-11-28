import QtQuick 2.0
import ".."
import "../edges"
import "../hud"
import "../paths"

import Neuronify 1.0
import QtQuick.Controls 2.1
import QtQuick.Particles 2.0
import QtGraphicalEffects 1.0

/*!
\qmltype Neuron

\brief The Neuron type is a base for all neurons.

Any implementation of a neuron should use this class as a base
and define its own NeuronEngine.
*/

Node {
    id: root
    objectName: "neuron"
    filename: "neurons/Neuron.qml"

    readonly property real voltage: root.engine.voltage

    property url imageSource
    property url inhibitoryImageSource
    property bool isNeuron: true

    radius: width / 2
    width: 72
    height: width
    color: inhibitory ? "#d66b88" : "#6baed6"

    preferredEdge: CurrentSynapse {}

    onFired: {
        fireAnimation.restart()
    }

    Image {
        id: image
        anchors.centerIn: parent
        width: 72
        height: width
        source: inhibitory ? inhibitoryImageSource : imageSource
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
    }

    Rectangle {
        property real thresholdRatio: Math.max(0.0, 0.5 * (voltage - engine.initialPotential) / (engine.threshold - engine.initialPotential))
        property real hyperpolarizationRatio: 0.0
        property real effectRatio: Math.max(thresholdRatio, hyperpolarizationRatio)

        anchors.fill: parent
        anchors.margins: 5.0
        border.width: effectRatio * 22.0
        border.color: Qt.rgba(1.0, 1.0, 1.0)
        color: "transparent"
        radius: width * 0.5
        smooth: true
        antialiasing: true
        opacity: effectRatio * 0.8
    }

    Rectangle {
        property real hyperpolarizationRatio: Math.max(0.0, (engine.initialPotential - voltage) / (engine.threshold - engine.initialPotential))

        anchors.centerIn: parent
        width: parent.width * Math.min(1.0, hyperpolarizationRatio)
        height: width
        color: Qt.rgba(0.5, 0.5, 0.5)
        radius: width * 0.5
        smooth: true
        antialiasing: true
        opacity: hyperpolarizationRatio * 0.4
    }

    Rectangle {
        id: fireIndicator
        anchors.fill: parent
        anchors.margins: 2.0
        radius: width * 0.5
        color: "#f7fbff"
        opacity: 0.0
        NumberAnimation {
            id: fireAnimation
            running: false
            target: fireIndicator
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 600
            easing.type: Easing.OutQuad
        }
    }

    Rectangle {
        id: dropIndicator
        anchors.centerIn: parent
        radius: width * 0.5
        color: "transparent"
        border.color: Qt.lighter(root.color, 1.0)
        border.width: 2.0

        width: 1.0
        height: width
        visible: false

        SequentialAnimation {
            id: dropAnimation
            running: false
            loops: Animation.Infinite
            NumberAnimation {
                target: dropIndicator
                property: "width"
                from: root.width
                to: root.width * 2
                duration: 300
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: dropIndicator
                property: "width"
                from: root.width * 2
                to: root.width
                duration: 800
                easing.type: Easing.OutQuad
            }
        }

        states: [
            State {
                when: dropArea.containsDrag && dropArea.drag.source.node !== root
                PropertyChanges {
                    target: dropIndicator
                    visible: true
                }
                PropertyChanges {
                    target: dropAnimation
                    running: true
                }
            }
        ]
    }

    Connector {
        color: inhibitory ? "#e41a1c" : "#6baed6"
        connectorColor: inhibitory ? "#e41a1c" : "#6baed6"
        initialPoint: Qt.point(root.width * 2 / 3, root.height * 2 / 3)
    }

    DropArea {
        id: dropArea
        anchors {
            fill: parent
            margins: -16
        }
        keys: [ "connector" ]
        onDropped: {
            receivedDrop(drop.source.node)
        }
    }
}
