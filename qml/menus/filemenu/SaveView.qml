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
//import Qt.labs.platform 1.0

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

    signal saved()
    required property FileManager fileManager

    Column {
        spacing: 16
        width: Math.min(480, parent.width)
        
        Button {
            anchors {
                right: parent.right
            }
            
            Material.theme: Material.Light
            width: 120
            text: qsTr("Save to computer")
            
            onClicked: {
                var result = fileManager.serializeState();
                var fileString = JSON.stringify(result, null, 4);
                saveDialog.saveFileContent(fileString);
                saved();
            }
        }

        AsyncFileDialog {
            id: saveDialog
        }
    }
}
