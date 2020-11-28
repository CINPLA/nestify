import QtQuick 2.6
import QtQuick.Controls 2.1
import QtMultimedia 5.0

import Neuronify 1.0

import "qrc:/qml/style"

/*!
\qmltype Node
\brief The Node type is the base of all items in Neuronify.

Node is a visual QML item that holds all common properties of items in
Neuronify.
It inherits NodeBase, which is its C++ counterpart.

In principle, \l Node and NodeBase could be the same class, but because
\l GraphEngine and \l NodeEngine cannot know about a QML type, we need to split
them up.
This is because we wish to use some QML features to define the functionality
of \l Node (such as \l MouseArea dragging), that does not allow us to put all
functionality of \l Node in C++.

\sa NodeBase, NodeEngine
*/

NodeBase {
    id: root
    signal clicked(var entity, var mouse)
    signal clickedConnector(var entity, var mouse)
    signal dragStarted(var entity)
    signal dragEnded(var entity)
    signal droppedConnector(var irregularSpikeGenerator, var connector)
    signal receivedDrop(var from)
    signal startConnectMultipleToThis
    signal startConnectMultipleFromThis
    signal fired

    property real snapGridSize: 1.0
    property var dragProxy
    property string name: "Unnamed node"
    property string label: ""
    property string objectName: "entity"
    property string filename: "Entity.qml"
    property real radius: width * 0.5
    property bool selected: false
    property vector2d velocity
    property bool dragging: false
    property var copiedFrom
    property color color: "cyan"
    property point connectionPoint: Qt.point(x + width / 2, y + height / 2)
    property Component controls
    property Item simulator
    property bool useDefaultMouseHandling: true
    property bool square: false
    property var removableChildren: [] // used by nodes such as TouchSensor that has child nodes
    property bool canReceiveConnections: true
    property bool snapToCenter: true

    property Component preferredEdge: Edge {}

    savedProperties: PropertyGroup {
        property alias x: root.x
        property alias y: root.y
        property alias label: root.label
        property alias inhibitory: root.inhibitory
        property alias engine: root.engine
    }

    Component.onCompleted: {
        if(engine) {
            engine.resetProperties();
            engine.resetDynamics();
        }
    }

    onEngineChanged: {
        if(engine) {
            engine.fired.connect(root.fired)
        }
    }

    function resolveAlias(index) {
        return undefined;
    }

    Rectangle{
        anchors.fill: labelBox
        color: "white"
        opacity: 0.5
        z: 98
    }

    Text {
        anchors.bottom: root.top
        id: labelBox
        z: 99
        text: qsTr(label)
        font.pixelSize: 20
    }

    Rectangle {
        id: selectionIndicator

        property color faintColor: Qt.rgba(0, 0.2, 0.4, 0.5)
        property color strongColor: Qt.rgba(0.4, 0.6, 0.8, 0.5)

        anchors.centerIn: root
        visible: root.selected

        color: "transparent"

        border.width: 2.0
        width: root.width + 12.0
        height: root.height + 12.0

        antialiasing: true
        smooth: true

        SequentialAnimation {
            running: selectionIndicator.visible
            loops: Animation.Infinite
            ColorAnimation { target: selectionIndicator; property: "border.color"; from: selectionIndicator.faintColor; to: selectionIndicator.strongColor; duration: 1000; easing.type: Easing.InOutQuad }
            ColorAnimation { target: selectionIndicator; property: "border.color"; from: selectionIndicator.strongColor; to: selectionIndicator.faintColor; duration: 1000; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        enabled: useDefaultMouseHandling
        anchors.fill: parent
        drag.target: root.dragProxy
        propagateComposedEvents: true

        onPressed: {
            root.dragging = true
            dragStarted(root)
            mouse.accepted = true;
        }

        onClicked: {
            root.clicked(root, mouse)
            mouse.accepted = true;
        }

        onReleased: {
            root.dragging = false
            dragEnded(root)
            mouse.accepted = true;
        }

        onDoubleClicked: {
            mouse.accepted = false;
        }
    }
}

