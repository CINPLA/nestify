import QtQuick 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import Neuronify 1.0

/*!
\qmltype FileManager
\inqmlmodule Neuronify
\ingroup neuronify-io
\brief A type to contain the save/load features

Neuronify saves configurations by storing the javascript code needed to create
the network, and loads files by evaluating the generated and saved js code.

The read/write part is done in \l{FileIO}, while this object just treats the file
as a js string.
*/

/*
  File format version documentation:

  2: v0.92
  3: v0.93
  4: v?
  5: v1.2
*/

Item {
    signal loadState(var fileUrl)

    property GraphEngine graphEngine: null
    property var workspace: null
    property var otherItems: []

    function showSaveDialog() {
        saveFileDialog.visible = true
    }

    function showLoadDialog() {
        loadFileDialog.visible = true
    }

    function objectify(obj) {
        if(!obj) {
            return undefined;
        }

        if(obj.isAlias) {
            return obj.aliasInfo();
        }
        var result = {};
        for(var i in obj.savedProperties) {
            var properties = obj.savedProperties[i].dump();
            for(var name in properties) {
                var prop = properties[name];
                if(typeof(prop) === "object") {
                    result[name] = objectify(prop);
                } else {
                    result[name] = prop;
                }
            }
        }
        return result;
    }

    function serializeState(filter) {
        var nodes = graphEngine.nodes
        var edges = graphEngine.edges
        var nodeList = [];
        var edgeList = [];
        var otherList = [];

        var counter = 0
        for(var i in nodes) {
            var node = nodes[i];
            if(filter && filter.indexOf(node) < 0) {
                continue
            }
            var savedProperties = objectify(node);
            if(!savedProperties) {
                console.log("ERROR: Could not objectify node " + node + " number " + i);
            }
            var nodeDump = {
                filename: node.filename,
                savedProperties: savedProperties
            };
            nodeList.push(nodeDump)
        }

        for(var i in edges) {
            var edge = edges[i];

            if(filter && (filter.indexOf(edge.itemA) < 0 || filter.indexOf(edge.itemB) < 0)) {
                continue
            }

            var savedProperties = objectify(edge);
            if(!savedProperties) {
                console.log("ERROR: Could not objectify edge " + edge + " number " + i);
            }

            var itemAEntityIndex = graphEngine.nodeIndex(edge.itemA)
            if(itemAEntityIndex === -1) {
                console.error("Could not find index of node " + edge.itemA + " in GraphEngine! Aborting dump!")
                return false
            }
            var itemBEntityIndex = graphEngine.nodeIndex(edge.itemB)
            if(itemBEntityIndex === -1) {
                console.error("Could not find index of node " + edge.itemB + " in GraphEngine! Aborting dump!")
                return false
            }

            var edgeDump = {
                filename: edge.filename,
                from: itemAEntityIndex,
                to: itemBEntityIndex,
                savedProperties: savedProperties
            }
            edgeList.push(edgeDump);
        }

        var result = {
            fileFormatVersion: 4,
            edges: edgeList,
            nodes: nodeList,
        };
        return result
    }

    function saveState(fileUrl) {
        console.log("Saving to " + fileUrl)
        var result = serializeState()
        var fileString = JSON.stringify(result, null, 4)

        return FileIO.writeSynchronously(fileUrl, fileString)
    }

    function read(fileUrl) {
        if(!fileUrl) {
            return
        }
        var stateFile = FileIO.readSynchronously(fileUrl)
        return stateFile
    }
}

