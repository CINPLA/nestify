TEMPLATE = app

TARGET = neuronify

android {
    TARGET = Neuronify
}

QT += qml quick widgets multimedia multimediawidgets charts sql svg xml gui core

CONFIG += c++14 qtquickcompiler

HEADERS += \
    src/io/fileio.h \
    src/core/graphengine.h \
    src/core/nodebase.h \
    src/core/nodeengine.h \
    src/neurons/neuronengine.h \
    src/retina/androidmultimediautils.h \
    src/retina/retinaengine.h \
    src/retina/retinapainter.h \
    src/retina/videosurface.h \
    src/retina/kernel.h \
    src/retina/kernels/gaborkernelengine.h \
    src/retina/kernels/abstractkernelengine.h \
    src/retina/kernels/dogkernelengine.h \
    src/io/standardpaths.h \
    src/neurons/rateengine.h \
    src/utility/mathhelper.h \
    src/core/neuronifyobject.h \
    src/io/propertygroup.h \
    src/retina/kernels/rectangularkernelengine.h \
    src/core/edgebase.h \
    src/core/edgeengine.h \
    src/io/downloadmanager.h \
    src/io/neuronifyfile.h \
    src/currents/current.h \
    src/currents/leakcurrent.h \
    src/currents/potassiumcurrent.h \
    src/currents/sodiumcurrent.h \
    src/currents/adaptationcurrent.h \
    src/compartments/compartmentengine.h

SOURCES += \
    src/io/fileio.cpp \
    src/main.cpp \
    src/core/nodebase.cpp \
    src/core/nodeengine.cpp \
    src/core/graphengine.cpp \
    src/neurons/neuronengine.cpp \
    src/retina/retinaengine.cpp \
    src/retina/retinapainter.cpp \
    src/retina/videosurface.cpp \
    src/retina/androidmultimediautils.cpp \
    src/retina/kernel.cpp \
    src/retina/kernels/gaborkernelengine.cpp \
    src/retina/kernels/abstractkernelengine.cpp \
    src/retina/kernels/dogkernelengine.cpp \
    src/io/standardpaths.cpp \
    src/neurons/rateengine.cpp \
    src/utility/mathhelper.cpp \
    src/core/neuronifyobject.cpp \
    src/io/propertygroup.cpp \
    src/retina/kernels/rectangularkernelengine.cpp \
    src/core/edgebase.cpp \
    src/core/edgeengine.cpp \
    src/io/downloadmanager.cpp \
    src/io/neuronifyfile.cpp \
    src/currents/leakcurrent.cpp \
    src/currents/potassiumcurrent.cpp \
    src/currents/sodiumcurrent.cpp \
    src/currents/adaptationcurrent.cpp \
    src/compartments/compartmentengine.cpp \
    src/currents/current.cpp


RESOURCES += qml.qrc \
    images.qrc \
    simulations.qrc \
    sounds.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

DISTFILES += \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/AndroidManifest.xml \
    android/gradlew.bat \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew \
    android/src/org/cinpla/neuronify/AlwaysOnActivity.java \
    qml/sensors/singletons/qmldir \
    COPYING.md \
    snapcraft.yaml \
    ios/iOS.plist \
    .travis/qt5-mac.sh \
    .travis.sh \
    .snapcraft/snapcraft.yaml \
    .snapcraft/parts/plugins/x-qt57.py \
    installer/config.xml \
    installer/meta/package.xml \
    installer/meta/license.txt \
    installer/config/config.xml \
    installer/packages/net.ovilab.neuronify/meta/package.xml \
    installer/packages/net.ovilab.neuronify/meta/license.txt \
    installer/packages/net.ovilab.neuronify/meta/installscript.qs \
    appveyor.yml \
    installer/packages/net.ovilab.neuronify/data/README.txt \
    .travis.yml \
    qml/backend/qmldir \
    .travis/Dockerfile \
    conanfile.txt

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

exists(libs/CuteVersioning/CuteVersioning.pri) {
    CUTEVERSIONING_GIT_DIR=$$PWD/.git
    CUTEVERSIONING_GIT_WORK_TREE=$$PWD
    include(libs/CuteVersioning/CuteVersioning.pri)
} else {
    error("Could not find CuteVersioning. Try running 'git submodule update --init --recursive' in Neuronify's root directory.")
}

include(libs/QmlPreviewer/qmlpreviewer.pri)

ios {
    QMAKE_INFO_PLIST = ios/iOS.plist
    ios_icon.files = $$files($$PWD/ios/icon/*.png)
    QMAKE_BUNDLE_DATA += ios_icon
    app_launch_images.files = $$PWD/ios/launch/Launch.xib
    QMAKE_BUNDLE_DATA += app_launch_images
}

macx {
    TARGET=Neuronify
    ICON = macos/icon.icns
    QMAKE_INFO_PLIST = macos/macos.plist
    #QMAKE_MAC_SDK = macosx10.9
    DISTFILES +=  \
    macos/icon.icns \
    macos/macos.plist
}

win32 {
    CONFIG += conan_basic_setup
    include(conanbuildinfo.pri)
}

WINRT_MANIFEST.name = Neuronify
WINRT_MANIFEST.background = $${LITERAL_HASH}399cdd
WINRT_MANIFEST.publisher = Ovilab
WINRT_MANIFEST.version = 1.2.2.0
WINRT_MANIFEST.description = Educational neural network app
WINRT_MANIFEST.capabilities += codeGeneration
WINRT_MANIFEST.logo_small=winrt/logo_44x44.png
WINRT_MANIFEST.logo_large=winrt/logo_150x150.png
WINRT_MANIFEST.logo_store=winrt/logo_50x50.png
WINRT_MANIFEST.logo_splash=winrt/logo_620x300.png
WINRT_MANIFEST.minVersion=10.0.10586.0
WINRT_MANIFEST.maxVersionTested=10.0.10586.0
