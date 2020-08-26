import QtQuick 2.5
import QtQuick.Controls 2.1 as QQC1
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
import Qt.labs.platform 1.0

import Neuronify 1.0
import CuteVersioning 1.0
import QtGraphicalEffects 1.0

import "qrc:/qml/backend"
import "qrc:/qml/controls"
import "qrc:/qml/hud"
import "qrc:/qml/io"
import "qrc:/qml/hud"
import "qrc:/qml/menus"
import "qrc:/qml/menus/filemenu"
import "qrc:/qml/tools"
import "qrc:/qml/store"
import "qrc:/qml/style"
import "qrc:/qml/ui"

Item {
    id: root

    signal requestClose

    property bool dragging: false
    property var currentSimulation
    property bool ignoreUnsavedChanges: false

    function open(file) {
        var simulation = NeuronifyFile.open(file)
        if(simulation) {
            neuronify.open(simulation)
            currentSimulation = simulation
        }
    }

    function save(simulation, callback) {
        currentSimulation = simulation
        neuronify.save(simulation, callback)
    }

    function saveCurrentOrOpenDialog(callback) {
        if(currentSimulation && currentSimulation.file) {
            neuronify.save(currentSimulation, callback)
            return
        }
        saveAs()
    }

    function saveAs() {
        fileView.open("save")
    }

    Component.onCompleted: {
        firstLoadTimer.start()
    }

    function firstLoad() {
//        neuronify.loadSimulation("qrc:/simulations/tutorial/tutorial_1_intro/tutorial_1_intro.nfy") // TODO replace with open
        open("file:///home/svenni/tmp/test.neuronify")
    }

    function tryClose() {
        if(ignoreUnsavedChanges) {
            return true
        }
        if(neuronify.hasUnsavedChanges) {
            unsavedDialog.openWithRequestedAction(root.requestClose)
            return false
        }
        return true
    }

    state: "view"

    Timer {
        // this is needed because workspaceFlickable doesn't have width at onCompleted
        id: firstLoadTimer
        interval: 200
        onTriggered: {
            root.firstLoad()
        }
    }

    MessageDialog {
        id: unsavedDialog
        property var requestedAction

        function openWithRequestedAction(action) {
            requestedAction = action
            open()
        }

        onYesClicked: {
            saveCurrentOrOpenDialog(function() {
                if (requestedAction) {
                    requestedAction()
                }
            })
        }
        onNoClicked: {
            ignoreUnsavedChanges = true
            if (requestedAction) {
                requestedAction()
            }
        }

        buttons: MessageDialog.Yes | MessageDialog.No | MessageDialog.Cancel

        text: "The document has been modified."
        informativeText: "Do you want to save your changes?"
    }

    DownloadManager {
        id: _downloadManager
    }

    Neuronify {
        id: neuronify
        anchors {
            left: itemMenu.right
            right: parent.right
            top: topMenu.bottom
            bottom: parent.bottom
        }
        clip: true
        autoPause: root.state != "view" && root.state != "creation"
        onBackgroundClicked: {
            itemModelLoader.source = ""
            propertiesPanel.revealed = false
        }
        focus: true
    }

    PlaybackControls {
        id: playbackControls
        revealed: true
        autoHideEnabled: false
        Binding {
            target: neuronify
            property: "playbackSpeed"
            value: playbackControls.playbackSpeed
        }
        Binding {
            target: playbackControls
            property: "playbackSpeed"
            value: neuronify.playbackSpeed
        }
    }

    EditMenu { // TODO rename to topmenu
        id: topMenu

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        height: 72

        onNewClicked: {
            fileView.open("new")
        }

        onSaveRequested: {
            saveCurrentOrOpenDialog()
        }

        onSaveAsRequested: {
            saveAs()
        }

        onOpenRequested: {
            fileView.open("open")
        }

        onCommunityClicked: {
            fileView.open("community")
        }

        // Editing

        onUndoClicked: {
            neuronify.undo()
        }

        onRedoClicked: {
            neuronify.redo()
        }

        onCutClicked: {
            neuronify.cut()
        }

        onCopyClicked: {
            neuronify.copy()
        }

        onPasteClicked: {
            neuronify.paste()
        }

        onDeleteClicked: {
            neuronify.deleteSelected()
        }

        // Settings

        onAccountClicked: {
            fileView.open("account")
        }

        onSettingsClicked: {
            fileView.open("settings")
        }
    }

    FileView {
        id: fileView
        anchors.fill: parent
        revealed: false
        currentSimulation: root.currentSimulation
        z: 99

        function runOrShowSaveDialog(action) {
            if (neuronify.hasUnsavedChanges) {
                unsavedDialog.openWithRequestedAction(action)
                return
            }
            action()
        }

        onLoadRequested: {
            runOrShowSaveDialog(function() {
                root.currentSimulation = undefined
                neuronify.loadSimulation(file)
                revealed = false
            })
        }

        onRunRequested: {
            runOrShowSaveDialog(function() {
                root.currentSimulation = simulation
                neuronify.open(simulation)
                revealed = false
            })
        }

        onSaveRequested: {
            root.save(simulation)
            revealed = false
        }

        onOpenRequested: {
            runOrShowSaveDialog(function() {
                root.open(file)
                revealed = false
            })
        }
    }

    HudShadow {
        id: leftMenuShadow
        anchors.fill: topMenu
        source: topMenu
        z: 38
    }

    Rectangle {
        id: itemMenu
        anchors {
            top: topMenu.bottom
            left: parent.left
            bottom: parent.bottom
        }
        color: "#e3eef9"
        width: 100
        z: 38

        ColumnLayout {
            id: creationLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                topMargin: 16
                leftMargin: 8
                rightMargin: 8
            }

            Repeater {
                id: itemListRepeater
                model: ListModel {
                    ListElement {
                        name: "Excitatory"
                        source: "qrc:/qml/neurons/LeakyNeuron.qml"
                        imageSource: "qrc:/images/neurons/leaky.png"
                        listSource: "qrc:/qml/hud/NeuronList.qml"
                    }
                    ListElement {
                        name: "Inhibitory"
                        listSource: "qrc:/qml/hud/InhibitoryNeuronList.qml"
                        source: "qrc:/qml/neurons/LeakyInhibitoryNeuron.qml"
                        imageSource: "qrc:/images/neurons/leaky_inhibitory.png"
                    }
                    ListElement  {
                        name: "Measurement"
                        listSource: "qrc:/qml/hud/MetersList.qml"
                        source: "qrc:/qml/meters/Voltmeter.qml"
                        imageSource: "qrc:/images/meters/voltmeter.png"
                    }
                    ListElement  {
                        name: "Generators"
                        source: "qrc:/qml/generators/CurrentClamp.qml"
                        imageSource: "qrc:/images/generators/current_clamp.png"
                        listSource: "qrc:/qml/hud/GeneratorsList.qml"
                    }
                    ListElement  {
                        name: "Compartments"
                        source: "qrc:/qml/compartments/HHCompartment.qml"
                        imageSource: "qrc:/images/generators/current_clamp.png"
                        listSource: "qrc:/qml/hud/CompartmentsList.qml"
                    }
                    ListElement  {
                        name: "Annotation"
                        source: "qrc:/qml/annotations/Note.qml"
                        listSource: "qrc:/qml/hud/AnnotationsList.qml"
                        imageSource: "qrc:/images/categories/annotation.png"
                    }
                }

                TopCreationItem {
                    id: creationItem

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: creationLayout.width

                    parentWhenDragging: root
                    name: model.name
                    source: model.source
                    imageSource: model.imageSource
                    selected: Qt.resolvedUrl(itemModelLoader.source) === Qt.resolvedUrl(model.listSource)
                    onClicked: {
                        if(Qt.resolvedUrl(itemModelLoader.source) === Qt.resolvedUrl(model.listSource)) {
                            itemModelLoader.source = ""
                            return
                        }
                        itemModelLoader.source = model.listSource
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 64
                Layout.maximumHeight: creationLayout.width + 16

                Label {
                    id: selectedLabel

                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }

                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                    text: ""
                    font.pixelSize: 12
                    horizontalAlignment: Qt.AlignHCenter
                    color: Style.mainDesktop.text.color
                    states: State {
                        when: neuronify.activeObject ? true : false
                        PropertyChanges {
                            target: selectedLabel
                            text: neuronify.activeObject.name
                        }
                    }
                }

                MaterialButton {
                    id: propertiesButton

                    anchors {
                        top: selectedLabel.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }

                    icon.category: "image"
                    icon.name: "tune"
                    color: Material.primary
                    text: "Properties"

                    onClicked: {
                        propertiesPanel.revealed = !propertiesPanel.revealed
                    }

                    states: State {
                        when: neuronify.activeObject ? false : true
                        PropertyChanges {
                            target: propertiesButton
                            opacity: 0.0
                            enabled: false
                        }
                    }
                }
            }
        }
    }

    HudShadow {
        anchors.fill: itemMenu
        source: itemMenu
        z: 29
    }

    Rectangle {
        id: itemSubMenu
        anchors {
            top: topMenu.bottom
            left: itemMenu.right
        }
        width: 240
        height: itemListView.height + 36
        visible: Qt.resolvedUrl(itemModelLoader.source) !== Qt.resolvedUrl("") ? true : false
        color: Material.background

        Flow {
            id: itemListView
            property int currentIndex: 0
            property alias listSource: itemModelLoader.source
            property int rows: Math.floor(parent.height / 96)
            property int columns: 2
            property real itemHeight: (height - spacing * (rows - 1)) / rows - 1
            property real itemWidth: (width - spacing * (columns - 1)) / columns - 1

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                leftMargin: 18
                rightMargin: 18
                topMargin: 18
            }

            spacing: 8

            Loader {
                id: itemModelLoader
                //                source: model.listSource
            }

            Repeater {
                model: itemModelLoader.item

                CreationItem {
                    id: creationItem2

                    //                                    width: itemListView.itemWidth
                    width: itemListView.itemWidth

                    parentWhenDragging: root

                    name: model.name
                    description: model.description
                    source: model.source
                    imageSource: model.imageSource

                    onDragActiveChanged: {
                        if(dragActive) {
                            root.dragging = true
                        } else {
                            root.dragging = false
                        }
                    }
                }
            }
        }
    }

    HudShadow {
        anchors.fill: itemSubMenu
        source: itemSubMenu
        visible: itemSubMenu.visible
        z: 20
    }

    PropertiesPanel {
        id: propertiesPanel

        property bool revealed: false

        anchors {
            left: itemMenu.right
            bottom: parent.bottom
        }
        activeObject: neuronify.activeObject

        states: [
            State {
                when: !propertiesPanel.revealed
                AnchorChanges {
                    target: propertiesPanel
                    anchors {
                        left: undefined
                        right: itemMenu.left
                    }
                }
            }
        ]

        transitions: [
            Transition {
                AnchorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        ]
    }

    HudShadow {
        anchors.fill: propertiesPanel
        source: propertiesPanel
        verticalOffset: -1
    }

    states: [
        State {
            name: "view"
            PropertyChanges { target: fileView; state: "hidden" }
            //            PropertyChanges { target: infoPanel; state: "hidden" }
        },
        State {
            name: "creation"
            extend: "view"
            PropertyChanges { target: topMenu; state: "small" }
            PropertyChanges { target: itemMenu; state: "" }
        },
        State {
            name: "welcome"
            extend: "view"
            PropertyChanges { target: fileView; state: "" }
            PropertyChanges { target: leftMenuShadow; opacity: 0.0 }
            PropertyChanges { target: topMenu; state: "small" }
        },
        State {
            name: "projects"
            extend: "view"
        },
        State {
            name: "help"
            extend: "view"
        }

    ]

    transitions: [
        Transition {
            animations: [
                animateCreation,
            ]
        },
        Transition {
            to: "community"
            animations: [
                animateCreation,
                animateCommunityTextIn
            ]
        },
        Transition {
            from: "community"
            animations: [
                animateCreation,
                animateCommunityTextOut
            ]
        }
    ]

    ParallelAnimation {
        id: animateCreation
        NumberAnimation {
            properties: "anchors.leftMargin"
            duration: 400
            easing.type: Easing.InOutQuad
        }
        ColorAnimation {
            properties: "color"
            duration: 400
            easing.type: Easing.InOutQuad
        }
    }

    SequentialAnimation {
        id: animateCommunityTextIn
        PauseAnimation {
            duration: 400
        }
    }
    SequentialAnimation {
        id: animateCommunityTextOut
        PauseAnimation {
            duration: 200
        }
    }

    Shortcut {
        sequence: StandardKey.Save
        onActivated: root.saveCurrentOrOpenDialog()
    }

    Shortcut {
        sequence: "Ctrl+Shift+S"
        onActivated: {
            root.saveAs()
        }
    }

}
