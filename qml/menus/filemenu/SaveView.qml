import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.3
import QtQuick.Particles 2.0
import QtQuick.Window 2.1

import QtCharts 2.1
import QtMultimedia 5.5
import Qt.labs.settings 1.0
import Qt.labs.folderlistmodel 2.1
import Qt.labs.platform 1.0 as Platform

import Neuronify 1.0
import CuteVersioning 1.0
import QtGraphicalEffects 1.0

import "qrc:/qml/backend"
import "qrc:/qml/controls"
import "qrc:/qml/hud"
import "qrc:/qml/io"
import "qrc:/qml/menus/filemenu"

import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Item {
    id: saveRoot

    signal saveRequested(var file)

    Column {
        spacing: 16
        width: Math.min(480, parent.width)
        
        Label {
            text: qsTr("Name:")
        }
        
        TextField {
            id: saveName
            anchors {
                left: parent.left
                right: parent.right
            }
            validator: RegExpValidator {
                regExp: /[a-zA-Z0-9\-\_ ]+/
            }
            
            placeholderText: "e.g. MySimulation"
            
            Binding {
                target: saveName
                property: "text"
                when: currentSimulation ? true : false
                value: currentSimulation ? currentSimulation.name : ""
            }
        }
        
        Label {
            text: qsTr("Description:")
        }
        
        TextArea {
            id: saveDescription
            anchors {
                left: parent.left
                right: parent.right
            }
            placeholderText: "e.g. Illustrates the effect of feedback inhibition."
            
            Binding {
                target: saveDescription
                property: "text"
                when: currentSimulation ? true : false
                value: currentSimulation ? currentSimulation.description : ""
            }
        }
        
        Label {
            text: "Screenshot preview:"
        }
        
        ShaderEffectSource {
            id: effectSource
            readonly property real aspectRatio: neuronify.width / neuronify.height
            width: parent.width * 0.6
            height: width / aspectRatio
            sourceItem: neuronify
        }
        
        Button {
            anchors {
                right: parent.right
            }
            
            Material.theme: Material.Light
            width: 120
            enabled: saveName.acceptableInput
            text: qsTr("Save")
            
            onClicked: {
                saveDialog.open()
            }
        }
        
        Platform.FileDialog {
            id: saveDialog
            fileMode: Platform.FileDialog.SaveFile
            nameFilters: ["Neuronify files (*.neuronify)"]
            defaultSuffix: ".neuronify"
            onAccepted: {
                var simulation = {
                    file: file,
                    name: saveName.text,
                    description: saveDescription.text
                }
                
                saveRequested(simulation)
            }
        }
    }
}
