#!/bin/bash
apt-get update -qq
apt-get install sudo
sudo apt-get build-dep -qq qt5-default libqt5opengl5 libqt5multimedia5
sudo apt-get install -qq snapcraft curl p7zip-full git bear clang clang-tidy build-essential libqt5opengl5-dev
bash .travis/qt5-ubuntu.sh $(pwd) extra-charts 3d base declarative graphicaleffects imageformats multimedia quickcontrols quickcontrols2 sensors svg tools translations xmlpatterns
export QTDIR=$(pwd)/5.7/gcc_64/
export PATH=$QTDIR/bin:$PATH
qmake
make clean # only necessary if run already
bear make # use bear to generate compile_commands.json
TIDY_RESULT=$(clang-tidy -header-filter="app/src/*" -checks='cppcoreguidelines-*,modernize-*,-clang-diagnostic-unused-command-line-argument,-clang-diagnostic-invalid-pp-token,' -p . src/*/*.cpp)
if [[ $TIDY_RESULT ]]; then
    echo "clang-tidy has warnings"
    exit 1
else
    echo "clang-tidy has no warnings"
fi
cp -r $QTDIR/lib .snapcraft/
cp -r $QTDIR/plugins .snapcraft/
cp -r $QTDIR/qml .snapcraft/
cp neuronify .snapcraft/
echo "Done"
