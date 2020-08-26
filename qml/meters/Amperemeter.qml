import QtQuick 2.0

import QtQuick.Layouts 1.1
import QtCharts 2.1
import QtGraphicalEffects 1.0

import Neuronify 1.0

import ".."
import "../edges"
import "../hud"
import "../paths"
import "../tools"
import "../style"

/*!
\qmltype Amperemeter
\inqmlmodule Neuronify
\ingroup neuronify-meters
\brief Reads the current and shows a trace plot
*/

Node {
    id: amperemeterRoot
    objectName: "amperemeter"
    filename: "meters/Amperemeter.qml"
    square: true
    name: "Amperemeter"

    property var connectionPlots: []
    property var colors: ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3",
        "#ff7f00", "#a65628", "#f781bf", "#999999"]

    property int currentSeries: 0

    property real timeFactor: 1000
    property real ampereFactor: 1e9

    property real timeRange: 100.0e-3

    property real timeSinceLastUpdate: 0
    property real lastUpdateTime: 0

    property alias minimumValue:  dummyAxisY.min
    property alias maximumValue:  dummyAxisY.max

    property real minimumTime: (time - timeRange) * timeFactor
    property real maximumTime: time * timeFactor

    property double fontSize : 14

    property real maximumPointCount: {
        if(Qt.platform.os === "android" || Qt.platform.os === "ios") {
            return 120.0
        } else {
            return 240.0
        }
    }

    property real time: 0.0
    property real realTime: 0.0
    property int numberOfEdges: 0

    controls: Component {
        MeterControls {
            meter: amperemeterRoot
            engine: amperemeterEngine
            sliderMinimum: -250
            sliderMaximum: 250
            unit: "mA"
            meterType: "Amperemeter"
        }
    }
    width: 320
    height: 240
    color: Style.meter.background

    snapToCenter: false
    preferredEdge: MeterEdge {}

    canReceiveConnections: false

    engine: NodeEngine {
        id: amperemeterEngine
        onStepped: {
            if((realTime - lastUpdateTime) > timeRange / maximumPointCount) {
                time = realTime
                lastUpdateTime = realTime
                for(var i in amperemeterRoot.connectionPlots) {
                    var connectionPlot = amperemeterRoot.connectionPlots[i]
                    var leakPlot = connectionPlot.leakPlot
                    var sodiumPlot = connectionPlot.sodiumPlot
                    var potassiumPlot = connectionPlot.potassiumPlot
                    var compartment = connectionPlot.connection.itemB

                    if(compartment) {
                        if(compartment.leakCurrent) {
                            leakPlot.addPoint(time * timeFactor, compartment.leakCurrent * ampereFactor)
                        }

                        if(compartment.sodiumCurrent) {
                            sodiumPlot.addPoint(time * timeFactor, compartment.sodiumCurrent * ampereFactor)
                        }

                        if(compartment.potassiumCurrent) {
                            potassiumPlot.addPoint(time * timeFactor, compartment.potassiumCurrent * ampereFactor)
                        }
                    }
                }
            }
            realTime += dt
        }
    }

    savedProperties: PropertyGroup {
        property alias width: amperemeterRoot.width
        property alias height: amperemeterRoot.height
        property alias maximumValue: amperemeterRoot.maximumValue
        property alias minimumValue: amperemeterRoot.minimumValue
    }


    onEdgeAdded: {
        numberOfEdges +=1
        var item = chartViewComponent.createObject(chartContainer);

        var leakPlot = item.leakPlot;
        var sodiumPlot = item.sodiumPlot;
        var potassiumPlot = item.potassiumPlot;

        var compartment = edge.itemB;
        item.showAxis = true
        item.showAxisLabel = true
        item.showLegend = true

        for(var i in connectionPlots) { // loop over all old plots
            var connectionPlot = connectionPlots[i]
            connectionPlot.item.showAxis = false
            connectionPlot.item.showAxisLabel = false
            connectionPlot.item.showLegend = false
        }

        var newList = connectionPlots

        var connectionPlot = {
            item: item,
            connection: edge,
            leakPlot: leakPlot,
            sodiumPlot: sodiumPlot,
            potassiumPlot: potassiumPlot,
            compartment: compartment,
        }

        newList.push(connectionPlot);
        connectionPlots = newList

    }

    onEdgeRemoved: {
        numberOfEdges -=1
        for(var i in connectionPlots) {
            var connectionPlot = connectionPlots[i]
            var connectionOther = connectionPlot.connection
            if(connectionOther === edge) {
                connectionPlot.neuron.fired.disconnect(connectionPlot.neuronFired);
                connectionPlot.item.destroy();
                connectionPlots.splice(i, 1);
                break
            }
        }
        currentSeries -= 1
        if(connectionPlots.length > 0){
            connectionPlots[connectionPlots.length -1 ].item.showAxis = true
            connectionPlots[connectionPlots.length -1 ].item.showAxisLabel = true
        }
    }


    Rectangle {
        id: background
        anchors.fill: parent
        color: parent.color
        smooth: true
        antialiasing: true
        visible: false

    }

    ItemShadow {
        anchors.fill: background
        source: background
    }

    ValueAxis {
        id: dummyAxisY
        min: -50.0e-9 * ampereFactor
        max: 100.0e-9 * ampereFactor
        gridVisible: false
        labelsVisible: false
        lineVisible: false
        tickCount: 2
    }

    ColumnLayout{
        id: chartContainer
        anchors.fill: parent

    }

    Component{
        id: chartViewComponent

        Item{
            id: chartItem
            property Plot leakPlot: leakSeries
            property Plot sodiumPlot: sodiumSeries
            property Plot potassiumPlot: potassiumSeries
            property string legend: "I_L=blue, I_Na=red, I_K=green"
            property string label: ""
            property bool showAxis: false
            property bool showAxisLabel: false
            property bool showLegend: false


            property color leakLineColor: "blue"
            property color sodiumLineColor: "red"
            property color potassiumLineColor: "green"

            Layout.fillWidth: true
            Layout.fillHeight: true
            width: 1
            height: 1

            // Axis label V and t
            Text{
                id: ylabel
                anchors{
                    verticalCenter: chartView.verticalCenter
                    left: chartView.left
                    leftMargin: 20
                }
                rotation: 270
                text: "I [nA]"
                visible: chartItem.showAxisLabel && (vMin.y - vMax.y - vMax.height) > width ? true : false
                font.pixelSize: amperemeterRoot.fontSize
            }

            Text{
                id: xlabel
                anchors{
                    horizontalCenter: chartView.horizontalCenter
                    bottom: chartView.bottom
                    bottomMargin: 10
                }

                text: chartItem.showAxisLabel ? "t [ms]" : ""
                font.pixelSize: amperemeterRoot.fontSize
            }

            //Time axis min/max:
            Text{
                id: tMin
                anchors{
                    verticalCenter: xlabel.verticalCenter
                    left: vMin.right
                }

                text: amperemeterRoot.minimumTime.toFixed(0)
                font.pixelSize: amperemeterRoot.fontSize
                visible: showAxis
            }
            Text{
                id: tMax
                anchors{
                    verticalCenter: xlabel.verticalCenter
                    right: chartView.right
                    rightMargin: 20
                }

                text: amperemeterRoot.maximumTime.toFixed(0)
                font.pixelSize: amperemeterRoot.fontSize
                visible: showAxis
            }

            //Voltage axis min/max:
            Text{
                id: vMin
                anchors{
                    right: ylabel.right
                    bottom: tMin.top
                }

                text: amperemeterRoot.minimumValue.toFixed(0)
                font.pixelSize: amperemeterRoot.fontSize
                visible: showAxis
            }
            Text{
                id: vMax
                anchors{
                    right: ylabel.right
                    top: chartView.top
                    topMargin: 13
                }

                text: amperemeterRoot.maximumValue.toFixed(0)
                font.pixelSize: amperemeterRoot.fontSize
                visible:showAxis
            }

            Text{
                id: titleText
                anchors{
                    top: chartView.top
                    topMargin: 2
                    horizontalCenter: chartView.horizontalCenter

                }

                text: label
                font.pixelSize: amperemeterRoot.fontSize

            }

            Text{
                id: legendText
                anchors{
                    top: chartView.top
                    topMargin: 2
                    horizontalCenter: chartView.horizontalCenter

                }

                text: legend
                visible: chartItem.showLegend
                font.pixelSize: amperemeterRoot.fontSize

            }

            ChartView {
                id: chartView
                anchors.fill: parent
                legend.visible: false
                smooth: true
                antialiasing: true
                backgroundColor: "transparent"
                enabled: false // disables mouse input
                margins.top: 0
                margins.bottom: 0
                margins.left: 10
                margins.right: 0


                Plot {
                    id: leakSeries
                    axisX: axisX
                    axisY: axisY
                    timeRange: amperemeterRoot.timeRange * timeFactor
                    color: chartItem.leakLineColor
                    width: 3.0
                }



                Plot {
                    id: sodiumSeries
                    axisX: axisX
                    axisY: axisY
                    timeRange: amperemeterRoot.timeRange * timeFactor
                    color: chartItem.sodiumLineColor
                    width: 3.0
                }



                Plot {
                    id: potassiumSeries
                    axisX: axisX
                    axisY: axisY
                    timeRange: amperemeterRoot.timeRange * timeFactor
                    color: chartItem.potassiumLineColor
                    width: 3.0
                }

                ValueAxis {
                    id: axisX
                    min: amperemeterRoot.minimumTime
                    max: amperemeterRoot.maximumTime
                    tickCount: 2 // IMPORTANT: Needs to be low because something gets
                    // recalculated everytime min/max changes and tickCount depends on this
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: showAxis
                    visible: false // IMPORTANT: Due to a bug in Qt Charts/Qt Graphics View,
                    // performance is degraded with time when text changes
                    // https://bugreports.qt.io/browse/QTBUG-59040
                }

                ValueAxis {
                    id: axisY
                    min: amperemeterRoot.minimumValue
                    max: amperemeterRoot.maximumValue
                    tickCount: 2
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: showAxis
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        color: Style.text.color
        visible: amperemeterRoot.connectionPlots.length < 1
        text: "Connect to compartment to see current"
    }

    ResizeRectangle {}

    Connector {
        color: Style.meter.border.color
//        visible: parent.selected || numberOfEdges < 1
    }
}
