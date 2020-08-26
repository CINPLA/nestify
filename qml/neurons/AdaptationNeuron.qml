import QtQuick 2.0
import QtQuick.Controls 2.0

import Neuronify 1.0

import "qrc:/qml"
import "qrc:/qml/controls"
import "qrc:/qml/neurons"
import "qrc:/qml/style"


Neuron {
    id: neuronRoot


    objectName: "adaptationNeuron"
    filename: "neurons/AdaptationNeuron.qml"
    imageSource: "qrc:/images/neurons/adaptive.png"
    inhibitoryImageSource: "qrc:/images/neurons/adaptive_inhibitory.png"
    name: "Adaptive neuron"

    engine: NeuronEngine {
        id: neuronEngine
        LeakCurrent {
            id: leakCurrent
            voltage: neuronEngine.voltage
            restingPotential: neuronEngine.restingPotential
        }
        AdaptationCurrent {
            id: adaptationCurrent
            voltage: neuronEngine.voltage
            restingPotential: neuronEngine.restingPotential
        }
        savedProperties: PropertyGroup {
            property alias adaptation: adaptationCurrent.adaptation
            property alias timeConstant: adaptationCurrent.timeConstant
        }
    }

    controls: Component {
        PropertiesPage {
            LabelControl {
                neuron: neuronRoot
            }
            SwitchControl{
                id: switchControl
                target: neuronRoot
                property: "inhibitory"
                checkedText: "Inhibitory"
                uncheckedText: "Excitatory"
            }
            AdaptationControl{
                current: adaptationCurrent
            }
            AdaptationTimeConstantControl{
                current: adaptationCurrent
            }

            // TODO add back list of fixed params

//            Text {
//                text: "Fixed parameters:"
//                font: Style.control.font
//                color: Style.text.color
//            }

//            Text {
//                id: subText
//                font: Style.control.subText.font
//                color: Style.control.subText.color
//                textFormat: Text.RichText
//                text: "V<sub>m</sub>: " +
//                      (neuronEngine.restingPotential * 1e3).toFixed(1)
//                      + " mV, " +
//                      "V<sub>m</sub>: " +
//                      (neuronEngine.initialPotential * 1e3).toFixed(1)
//                      + " mV, " +
//                      "V<sub>thres</sub>: " +
//                      (neuronEngine.threshold * 1e3).toFixed(1)
//                      + " mV<br>" +
//                      "C<sub>m</sub>: " +
//                      (neuronEngine.capacitance * 1e9).toFixed(1)
//                      + " nF, " +
//                      "R<sub>m</sub>: " +
//                      (leakCurrent.resistance * 1e-3).toFixed(1)
//                      + " kΩ,<br>" +
//                      "τ<sub>r</sub>: "+
//                      0
//                      + " ms, "
//            }

//            ConnectMultipleControl {
//                node: neuronRoot
//            }

//            ResetControl {
//                engine: neuronEngine
//            }

        }
    }
}

