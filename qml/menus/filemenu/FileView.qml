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
    id: root

    property bool revealed: true
    property url latestFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/neuronify"
    property var currentSimulation
    required property FileManager fileManager

    signal saved()
    signal runRequested(var simulation)
    signal loadRequested(url file) // TODO remove

    Material.theme: Material.Dark

    function open(name) {
        var index = 0
        for(var i in viewColumn.children) {
            var child = viewColumn.children[i]
            if(child.identifier === name) {
                viewColumn.currentIndex = index
                break
            }
            index += 1
        }
        root.revealed = true
    }

    Settings {
        property alias latestFolder: root.latestFolder
    }
    
    MouseArea {
        id: fileViewMouseArea
        anchors.fill: parent
        onWheel: {
            return
        }
    }
    
    Item {
        id: fileViewContent
        anchors.fill: parent
        
        Rectangle {
            id: background
            anchors.fill: parent
            color: Material.primary
            opacity: 1.0
        }
        
        Item {
            id: fileViewMenu
            anchors {
                left: parent.left
                leftMargin: 48
                top: parent.top
                topMargin: 64
            }
            width: 196
            height: buttonContainer.height
            
            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                
                width: 2
                color: "white"
                opacity: 0.2
            }

            Column {
                id: buttonContainer
                anchors {
                    left: parent.left
                    right: parent.right
                }

                FileMenuItem {
                    name: "Back"
                    onClicked: {
                        root.revealed = false
                    }
                }

                Item {
                    height: 32
                    width: 32
                }

                FileMenu {
                    id: viewColumn
                    property string currentName
                    currentIndex: 0

                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    Component.onCompleted: {
                        reloadComponent()
                    }

                    function reloadComponent() {
                        currentName = children[currentIndex].name
                        stackView.replace(children[currentIndex].component)
                    }

                    onCurrentIndexChanged: {
                        reloadComponent()
                    }

                    FileMenuItem {
                        identifier: "new"
                        name: "New"
                        component: NewView {
                            onLoadRequested: {
                                root.loadRequested(filename)
                            }
                        }
                    }

                    FileMenuItem {
                        id: communityItem
                        signal refresh()
                        identifier: "community"
                        name: "Community"
                        visible: Qt.platform.os !== "wasm"

                        Component {
                            id: simulationComponent
                            StoreSimulation {
                                onRunClicked: {
                                    runRequested(simulation)
                                    stackView.pop()
                                }
                                onDeleted: {
                                    // Refresh whichever of these is open
                                    communityItem.refresh()
                                    mySimulationsItem.refresh()

                                    stackView.pop()
                                }
                            }
                        }
                    }

                    FileMenuItem {
                        id: mySimulationsItem
                        signal refresh()
                        name: "My simulations"
                        visible: Firebase.loggedIn
                        component: MySimulations {
                            id: mySimulations
                            Connections {
                                target: mySimulationsItem
                                onRefresh: mySimulations.refresh()
                            }

                            onUploadClicked: stackView.push(uploadComponent)
                            onItemClicked: {
                                stackView.push(simulationComponent)
                                stackView.currentItem.objectData = simulationData
                            }
                        }

                        Component {
                            id: uploadComponent
                            UploadView {
                                onUploadCompleted: {
                                    stackView.pop()
                                    mySimulationsItem.refresh()
                                }
                            }
                        }
                    }

                    FileMenuItem {
                        identifier: "account"
                        name: "Account"
                        visible: Qt.platform.os !== "wasm"
                        component: AccountView {
                        }
                    }

                    FileMenuItem {
                        identifier: "about"
                        name: "About"
                        component: AboutView {
                        }
                    }
                }
            }
        }

        Item {
            id: titleRow
            anchors {
                top: fileViewMenu.top
                left: fileViewMenu.right
                leftMargin: 48
            }

            height: fileViewTitle.height
            MouseArea {
                id: stackBackButton
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: height

                onClicked: {
                    stackView.pop(null)
                }

                MaterialIcon {
                    anchors {
                        fill: parent
                        margins: 6
                    }
                    name: "arrow_back"
                    color: "white"
                }
            }

            Text {
                id: fileViewTitle
                anchors {
                    top: parent.top
                    left: stackBackButton.right
                    leftMargin: 8
                }

                color: "white"
                font.pixelSize: 48
                font.weight: Font.Light
                text: viewColumn.currentName
            }
        }

        StackView {
            id: stackView
            anchors {
                left: titleRow.left
                top: titleRow.bottom
                right: parent.right
                bottom: parent.bottom
                topMargin: 32
                rightMargin: 0
            }
            clip: true

            state: "top"

            replaceEnter: Transition {
                ParallelAnimation {
                    XAnimator {
                        from: 400
                        to: 0
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            replaceExit: Transition {
                ParallelAnimation {
                    XAnimator {
                        from: 0
                        to: -400
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 400
                        easing.type: Easing.OutCubic
                    }
                }
            }

            states: [
                State {
                    name: "top"
                    when: stackView.depth < 2
                    AnchorChanges {
                        target: fileViewTitle
                        anchors.left: parent.left
                    }
                    PropertyChanges {
                        target: fileViewTitle
                        anchors.leftMargin: 0
                    }
                    PropertyChanges {
                        target: stackBackButton
                        opacity: 0.0
                    }
                }
            ]
            transitions: [
                Transition {
                    to: "top"
                    reversible: true
                    SequentialAnimation {
                        NumberAnimation {
                            property: "opacity"
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                        AnchorAnimation {
                            duration: 600
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            ]
        }
    }
    states: [
        State {
            name: "hidden"
            when: !root.revealed
            PropertyChanges {
                target: root
                enabled: false
                opacity: 0.0
            }
            PropertyChanges {
                target: fileViewContent
                opacity: 0.0
            }
            PropertyChanges {
                target: titleRow
                opacity: 0.0
            }
            PropertyChanges {
                target: titleRow
                anchors.leftMargin: 1024
            }
            PropertyChanges {
                target: stackView
                anchors.rightMargin: -1024
            }
            PropertyChanges {
                target: fileViewMenu
                opacity: 0.0
            }
            PropertyChanges {
                target: fileViewMouseArea
                enabled: false
            }
            AnchorChanges {
                target: viewColumn
                anchors {
                    left: undefined
                    right: parent.left
                }
            }
        }
    ]

    transitions: [
        Transition {
            NumberAnimation {
                targets: [titleRow, fileViewMenu]
                properties: "opacity"
                duration: 600
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                targets: root
                properties: "opacity"
                duration: 600
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                properties: "anchors.leftMargin,anchors.rightMargin"
                duration: 360
                easing.type: Easing.OutQuad
            }
            AnchorAnimation {
                targets: viewColumn
                duration: 400
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: fileViewContent
                properties: "opacity"
                duration: 400
            }
        }
    ]
}
