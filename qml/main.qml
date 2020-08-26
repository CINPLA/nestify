import QtQuick 2.2
import Qt.labs.settings 1.0
import CuteVersioning 1.0
import QtQuick.Window 2.0
import QtQuick.Controls 2.1
import Neuronify 1.0

import "qrc:/qml/style"

ApplicationWindow {
    id: root

    property real startupTime: 0

//    visibility: ApplicationWindow.FullScreen
    visible: true
    width: 1136
    height: 640
    title: qsTr("Neuronify " + Version.latestTag)

    Component.onCompleted: {
        console.log("ApplicationWindow load completed " + Date.now());
        startupTime = Date.now();

        // Convert files from older versions of Neuronify
        for (var i = 0; i < 6; i++) {
            var name = "savedata/custom" + i + ".nfy"
            var filename = StandardPaths.locate(StandardPaths.AppConfigLocation, name)
            if (Qt.resolvedUrl(filename) == "") {
                continue
            }
            var newName = "savedata/custom" + i + ".neuronify"
            var newFilename = StandardPaths.writableLocation(StandardPaths.AppConfigLocation, newName)
            FileIO.read(filename, function(data) {
                if (!FileIO.exists(newFilename)) {
                    NeuronifyFile.save(newFilename, "Old save " + i, "Imported from old version of Neuronify", data)
                    savedataSettings.performed = true
                    savedataSettings.location = StandardPaths.writableLocation(StandardPaths.AppConfigLocation, "savedata")
                }
            })
        }
    }

    Settings {
        id: savedataSettings
        property bool performed
        property url location
        category: "converted_saves"
    }

    Dialog {
        id: copyDialog

        width: 400
        height: 300

        title: "Savefiles converted"
        standardButtons: Dialog.Ok


    }

    onWidthChanged: {
        resetStyle()
    }

    onHeightChanged: {
        resetStyle()
    }

    onClosing: {
        // Hack to keep back button from closing app
        console.log("onClosing")
        if (Qt.platform.os === "android"){
            close.accepted = false
            return
        }
        if(!mainDesktop.tryClose()) {
            close.accepted = false
            return
        }
        console.log("Neuronify closing...")
    }

    function resetStyle() {
        Style.reset(width, height, Screen.pixelDensity)
    }

    Settings {
        id: settings
        property alias width: root.width
        property alias height: root.height
        property alias x: root.x
        property alias y: root.y
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Regular.ttf"
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Light.ttf"
    }

    FontLoader {
        source: "qrc:/fonts/roboto/Roboto-Bold.ttf"
    }

    MainDesktop {
        id: mainDesktop
        anchors.fill: parent
        focus: true
        onRequestClose: {
            console.log("Close requested")
            root.close()
        }
    }
}
