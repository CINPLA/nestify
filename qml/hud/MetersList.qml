import QtQuick 2.0

ListModel {
    ListElement {
        name: "Voltmeter"
        description: "Measures the membrane potential of neurons"
        source: "qrc:/qml/meters/Voltmeter.qml"
        imageSource: "qrc:/images/meters/voltmeter.png"
    }
    ListElement {
        name: "Amperemeter"
        description: "Measures the different currents"
        source: "qrc:/qml/meters/Amperemeter.qml"
        imageSource: "qrc:/images/meters/amperemeter.png"
    }
    ListElement {
        name: "Spike detector"
        description: "Shows firing times of neurons"
        source: "qrc:/qml/meters/SpikeDetector.qml"
        imageSource: "qrc:/images/meters/spikemeter.png"
    }
    ListElement {
        name: "Firing rate plot"
        description: "Shows firing rate of neurons"
        source: "qrc:/qml/meters/RatePlot.qml"
        imageSource: "qrc:/images/meters/ratePlot.png"
    }
    ListElement {
        name: "Loudspeaker"
        description: "Plays a sound when a connected neuron fires"
        source: "qrc:/qml/meters/Loudspeaker.qml"
        imageSource: "qrc:/images/meters/loudspeaker.png"
    }
}
