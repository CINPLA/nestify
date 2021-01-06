import QtQuick 2.5
import QtCharts 2.1
import Neuronify 1.0
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ".."
import "../controls"
import "../edges"
import "../hud"
import "../paths"
import "../tools"
import "../style"

/*!
\qmltype SpikeDetector
\inqmlmodule Neuronify
\ingroup neuronify-meters
\brief Shows firing times of neurons.
*/


Node {
    id: rasterRoot

    property string label: ""
    property real time: 0.0
    property real timeRange: 100.0e-3
    property real timeScale: 1e-3
    property bool showLegend: true

    property var neurons: []

    property real realTime: 0.0
    property real timeSinceLastUpdate: 0
    property real lastUpdateTime: 0
    property real maximumPointCount: 120
    property int numberOfEdges: 0

    property int stopped: 0
    property int recording: 1
    property int error: 2

    property int recordingState: stopped

    objectName: "spikeDetector"
    filename: "meters/SpikeDetector.qml"
    square: true
    name: "Spike detector"

    width: 320
    height: 240
    color: "#deebf7"

    canReceiveConnections: false

    preferredEdge: MeterEdge {}

    savedProperties: PropertyGroup {
        property alias label: rasterRoot.label
        property alias width: rasterRoot.width
        property alias height: rasterRoot.height
        property alias timeRange: rasterRoot.timeRange
        property alias showLegend: rasterRoot.showLegend
    }

    engine: NodeEngine {
        onStepped: {
            if((realTime - lastUpdateTime) > timeRange / maximumPointCount) {
                time = realTime
                lastUpdateTime = realTime
            }
            realTime += dt
        }
    }

    controls: Component {
        PropertiesPage {
            Label {
                text: "Label:"
                Layout.fillWidth: true
            }

            TextField {
                id: labelField
                Layout.fillWidth: true
                text: rasterRoot.label
                selectByMouse: true
                Binding {
                    target: rasterRoot
                    property: "label"
                    value: labelField.text
                }
                Binding {
                    target: labelField
                    property: "text"
                    value: rasterRoot.label
                }
            }

            BoundSlider {
                target: rasterRoot
                property: "timeRange"
                text: "Time range"
                unit: "ms"
                unitScale: 1e-3
                minimumValue: 1.0e-3
                maximumValue: 1000.0e-3
                stepSize: 10.0e-3
            }

            Button {
                text: "Record"
                onPressed: startRecording()
            }

            Button {
                text: "Stop"
                onPressed: stopRecording()
            }
        }
    }

    function refreshCategories() {
        var toRemove = []
        for(let i in axisY.categoriesLabels) {
            toRemove.push(axisY.categoriesLabels[i])
        }
        for(let i in toRemove) {
            var label = toRemove[i]
            axisY.remove(label)
        }
        for(let i in neurons) {
            var neuron = neurons[i]
            var position = parseFloat(i) + 1.5
            axisY.append(" " + neuron.label, position)
        }
    }

    function startRecording() {
        const callback = (folder) => {
            const prefix = new Date().toISOString().split(".")[0].replace(/:/g, "");
            const suffix = "csv";
            const sanitizedLabel = label.replace(' ', '_').replace(/\W/g, '');
            const componentLabel = sanitizedLabel.length > 0 ? sanitizedLabel : "spike-detector";
            recorder.fileName = Qt.resolvedUrl(`${folder}/${prefix}-${componentLabel}.${suffix}`);
            recorder.start();
            rasterRoot.recordingState = recording;
        };
        simulator.verifyRecordingFolder(callback);
    }

    function stopRecording() {
        rasterRoot.recordingState = stopped;
    }


    onEdgeAdded: {
        stopRecording();
        numberOfEdges +=1
        var neuron = edge.itemB
        var newList = neurons
        neurons.push(neuron)
        neuron.onLabelChanged.connect(refreshCategories)
        neuron.fired.connect(function() {
            for(var i in neurons) {
                var neuron2 = neurons[i]
                if(neuron2 === neuron) {
                    scroller.append(time / timeScale, parseFloat(i) + 1.0)
                    recorder.addSpike(realTime, neuron);
                }
            }
        });
        neurons = newList

        refreshCategories()
    }

    onEdgeRemoved: {
        stopRecording();
        numberOfEdges -=1
        var neuron = edge.itemB
        var newList = neurons
        var index = newList.indexOf(neuron)
        if(index > -1) {
            newList.splice(index, 1)
            neurons = newList
        }
        neuron.onLabelChanged.disconnect(refreshCategories)

        scatterSeries.clear()
        refreshCategories()
    }

    FileTextStreamOut {
        id: recorder

        function start() {
            write(`"time [ms]","neuron"\n`);
        }

        function addSpike(time, neuron) {
            if (rasterRoot.recordingState !== recording) {
                return;
            }

            const label = neuron.label.length > 0 ? neuron.label : "unnamed";
            write(`${time},"${label}"\n`);
        }
    }


    Rectangle {
        anchors.fill: parent
        color: parent.color
        border.color: Style.meter.border.color
        border.width: Style.meter.border.width
        smooth: true
        antialiasing: true
    }

    Rectangle {
        anchors {
            top: parent.top
            left: parent.left
            margins: 8
        }
        width: 16
        height: 16
        radius: width / 2
        color: {
            if(rasterRoot.recordingState === recording) {
                return "red";
            } else {
                return "grey";
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (rasterRoot.recordingState === recording) {
                    stopRecording()
                } else {
                    startRecording()
                }
            }
        }
    }


    ChartView {
        anchors.fill: parent
        enabled: false // disable mouse input
        legend.visible: false
        backgroundColor: "transparent"

        margins.top: 0
        margins.bottom: 0
        margins.left: 0
        margins.right: 0

        ScatterSeries {
            id: scatterSeries
            useOpenGL: false // TODO use OpenGL once points are bigger again
            borderWidth: 0.2
            markerSize: 8.0
            axisX: ValueAxis {
                id: axisX
                min: (time - timeRange) / timeScale
                max: time / timeScale
                tickCount: 2
                gridVisible: false
                labelsFont.pixelSize: 14
                labelFormat: "%.0f"
                titleFont.weight: Font.Normal
                titleFont.pixelSize: 14
                titleText: rasterRoot.showLegend ? "t [ms]" : ""
                visible: false // IMPORTANT: Due to a bug in Qt Charts/Qt Graphics View,
                // performance is degraded with time when text changes
                // https://bugreports.qt.io/browse/QTBUG-59040
            }
            axisY: CategoryAxis {
                id: axisY
                min: 0.0
                max: neurons.length + 1.0
                startValue: 0.5
                gridVisible: false
                tickCount: 0
                lineVisible: false
                labelsFont.pixelSize: 14
                titleFont.weight: Font.Normal
                titleFont.pixelSize: 14
                //                titleText: rasterRoot.showLegend ? "Cell" : ""
            }
        }
        ChartScroller {
            id: scroller
            series: scatterSeries
            timeRange: rasterRoot.timeRange / rasterRoot.timeScale
        }
    }

    ResizeRectangle {}

    Connector {
        color: Style.meter.border.color
    }
}
