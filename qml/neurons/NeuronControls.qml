import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1

import Neuronify 1.0

import ".."

Item {
    id: neuronControlsRoot

    signal deleteClicked

    property NeuronEngine engine: null

    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Text {
            text: engine.voltage.toFixed(0) + " mV"
            anchors.right: parent.right
        }
        Text {
            text: "Synaptic output: "+ engine.fireOutput.toFixed(1) + " mS"
        }
        CheckBox {
            id: inhibitoryCheckbox
            text: "Inhibitory"
            checked: (engine.fireOutput < 0.0)
        }
        Slider {
            id: fireOutputSlider
            minimumValue: 0.
            maximumValue: 10.
            stepSize: 0.1
            tickmarksEnabled: true
            Layout.fillWidth: true
            value: Math.abs(engine.fireOutput)
        }
        Binding {
            target: engine
            property: "fireOutput"
            value: (inhibitoryCheckbox.checked ? -1.0 : 1.0) * fireOutputSlider.value
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
