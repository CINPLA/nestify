import QtQuick 2.0

ListModel {
    ListElement {
        name: "Hodgkin-Huxley"
        description: "Hodgkin-Huxley compartment"
        source: "qrc:/qml/compartments/HHCompartment.qml"
        imageSource: "qrc:/images/generators/current_clamp.png"
    }

    ListElement {
        name: "Passive"
        description: "Passive compartment"
        source: "qrc:/qml/compartments/SimpleCompartment.qml"
        imageSource: "qrc:/images/generators/current_clamp.png"
    }
}
