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
import Qt.labs.platform 1.0

import Neuronify 1.0
import CuteVersioning 1.0
import QtGraphicalEffects 1.0

import "qrc:/qml/controls"
import "qrc:/qml/hud"
import "qrc:/qml/io"
import "qrc:/qml/menus/filemenu"
import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Rectangle {
    id: root
    
    property real textOpacity: 1.0

    // TODO Replace with event system from Atomify
    signal newClicked()
    signal saveAsRequested()
    signal openRequested()
    signal uploadClicked()
    signal communityClicked()

    signal undoClicked()
    signal redoClicked()
    signal cutClicked()
    signal copyClicked()
    signal pasteClicked()
    signal deleteClicked()

    signal accountClicked()
    
    Material.theme: Material.Dark

    color: Material.primary
    z: 40
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    
    RowLayout {
        id: menuColumn

        property bool containsMouse: mouseArea.containsMouse

        anchors {
            fill: parent
            leftMargin: 24
            rightMargin: 8
            topMargin: 8
            bottomMargin: 6
        }
        spacing: 6
        LeftMenuButton {
            duration: 200
            icon.category: "editor"
            icon.name: "insert drive file"
            text: "New"
            onClicked: {
                newClicked()
            }
        }
        LeftMenuButton {
            text: "Open"
            icon.name: "folder_open"
            icon.category: "file"
            duration: 250
            onClicked: {
                openRequested()
            }
        }
        LeftMenuButton {
            text: "Save as"
            icon.category: "file"
            icon.name: "file download"
            duration: 350
            onClicked: {
                saveAsRequested()
            }
        }
        LeftMenuButton {
            text: "Community"
            icon.category: "social"
            icon.name: "people"
            duration: 400
            visible: Qt.platform.os !== "wasm"
            onClicked: {
                communityClicked()
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        LeftMenuButton {
            text: "Undo"
            icon.category: "content"
            icon.name: "undo"
            duration: 500
            onClicked: {
                undoClicked()
            }
        }
        LeftMenuButton {
            text: "Redo"
            icon.category: "content"
            icon.name: "redo"
            duration: 450
            onClicked: {
                redoClicked()
            }
        }
        LeftMenuButton {
            text: "Cut"
            icon.category: "content"
            icon.name: "content cut"
            duration: 400
            onClicked: {
                cutClicked()
            }
        }
        LeftMenuButton {
            text: "Copy"
            icon.category: "content"
            icon.name: "content copy"
            duration: 350
            onClicked: {
                copyClicked()
            }
        }
        LeftMenuButton {
            text: "Paste"
            icon.category: "content"
            icon.name: "content paste"
            duration: 300
            onClicked: {
                pasteClicked()
            }
        }
        LeftMenuButton {
            text: "Delete"
            icon.category: "action"
            icon.name: "delete"
            duration: 250
            onClicked: {
                deleteClicked()
            }
        }
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        LeftMenuButton {
            text: "Account"
            icon.name: "account_circle"
            icon.category: "action"
            visible: Qt.platform.os !== "wasm"
            duration: 250
            onClicked: {
                accountClicked()
            }
        }
    }
    
    states: [
        State {
            name: "small"
            PropertyChanges { target: root; width: 72 }
            PropertyChanges { target: logoTextCopy; opacity: 0.0 }
            PropertyChanges { target: root; textOpacity: 0.0 }
        },
        State {
            name: "hidden"
            //                AnchorChanges {
            //                    target: leftMenu
            //                    anchors {
            //                        left: undefined
            //                        right: parent.left
            //                    }
            //                }
        }
        
    ]
    
    transitions: [
        Transition {
            NumberAnimation {
                target: root
                properties: "width,textOpacity"
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: leftMenuShadow
                properties: "opacity"
                duration: 0
            }
            AnchorAnimation {
                duration: 0
            }
            NumberAnimation {
                target: logoTextCopy
                property: "opacity"
                duration: 400
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "hidden"
            to: ""
            AnchorAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
