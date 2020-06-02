#!/bin/bash
export QTDIR=/opt/qt5/5.9.6/gcc_64
export PATH=$QTDIR/bin:$PATH
SNAP_DUMP=snapdump
qmake
make -j8
mkdir -p ${SNAP_DUMP}
cp -r $QTDIR/bin ${SNAP_DUMP}/
cp -r $QTDIR/lib ${SNAP_DUMP}/
cp -r $QTDIR/plugins ${SNAP_DUMP}/
cp -r $QTDIR/plugins/platforms ${SNAP_DUMP}/
cp -r $QTDIR/qml ${SNAP_DUMP}/
cp neuronify ${SNAP_DUMP}/bin/neuronify
