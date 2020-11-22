[![Build Status](https://travis-ci.org/CINPLA/neuronify.svg?branch=dev)](https://travis-ci.org/CINPLA/neuronify)
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
# Neuronify

An educational neural network app using the integrate-and-fire method.
A scientific description of the underlying computational model and the app can be found in the paper published in eNeuro: Dragly et al (2017) DOI: https://doi.org/10.1523/ENEURO.0022-17.2017

## Download Neuronify

Visit the [Neuronify website](http://ovilab.net/neuronify) to download the latest version for your operating system.

## Building Neuronify

### Prerequisites

1. Download Qt from http://www.qt.io/download-open-source/
2. Run the installer and follow the instructions

### Downloading and building

3. Clone the git repo: git@github.com:CINPLA/neuronify.git
4. Open Qt Creator
5. In Qt Creator, use Open Project, go to the neuronify folder and open nestify.pro or neuronify.pro, whichever is present
6. Under configure project that shows up, mark Desktop Qt 5.4.0 GCC and unmark Desktop before pressing Configure Project
7. Press Run (green triangle) and it should hopefully build and run.

## Releasing Neuronify

This information is mostly relevant to Neuronify developers who want to help deploying new
versions of Neruonify.

### Deploying Neuronify as a Snap package

This is handled automatically by our Travis CI setup.

To deploy, simply create a new tag:

    git tag -a v1.x.y -m "Release of version 1.x.y"

Then push this:

    git push --tags

Travis CI should pick up on this and build the release and push it to Ubuntu's snap store.
You can track the build status at https://travis-ci.org/CINPLA/neuronify/

Once finished, test it locally by running

    sudo snap install neuronify --edge

If it works, you can log into the Ubuntu app store and change the channel from `edge` to `stable`.

**Note:** Once a year, we need to update the encryption keys.
To do this, run the following on your machine:

    snapcraft enable-ci travis --refresh

This will add an `after_success` clause at the end of `.travis.yml`.
Copy this and overwrite the existing `after_success` clause further up in the file,
in the build matrix, under the linux OS configuration.
That is, make sure that the openssl command references the latest `*_key` and `*_iv`
environment values.

### Creating a deployable .zip on Windows

1. In Qt Creator, you may choose to build using the MinGW or Visual Studio 2013 (MSVC) compilers depending on your installation. We recommend Visual Studio because this adds support for systems without OpenGL drivers already installed.
2. Compile in release mode. Otherwise the build will be gigantic.
3. Open Windows PowerShell.
4. Run the following command:
    - if you are using MinGW:

        $env:Path = "C:\Qt\5.4\mingw491_32\bin"

    - if you are using MSVC:

        $env:Path = "C:\Qt\5.4\msvc2013\bin"

5. Note that the names of the folders may vary if you have a different Qt version. These above are the folders for Qt 5.4 and Visual Studio 2013.
5. Use cd to navigate to the build folder, above the release and debug folders.
5. Delete everything except neuronify.exe inside the release folder.
6. Run the following command to let Qt help you with deployment:

    windeployqt.exe -quick -quickwidgets -multimediaquick -multimedia -opengl -quickparticles -quickwidgets -qmldir ../neuronify release

7. Copy all folders in C:\Qt\5.7\qml into the app folder. These are not all necessary, but the deploy tool doesn't catch all, and if any are missing, the app won't start.
7. Next, you will need to copy the following files to your build folder manually:
    - if you are using MinGW:

        - C:\Windows\SysWOW64\msvcp120.dll
        - C:\Windows\SysWOW64\msvcr120.dll
        - C:\Qt\5.4\mingw491_32\bin\libgcc_s_dw2-1.dll
        - C:\Qt\5.4\mingw491_32\bin\libstdc++-6.dll
        - C:\Qt\5.4\mingw491_32\bin\libwinpthread-1.dll

    - if you are using MSVC:
        - from C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\redist\x64\Microsoft.VC120.CRT:
        - msvcp120.dll
        - msvcr120.dll

8. Zip the whole folder, and you should be good to go
9. Note that these are the files you need to copy if you are using Qt 5.4 and Visual Studio 2013. If you are using a newer version, you may want to use a newer set of files. Please refer to the documentation for more information:

http://doc.qt.io/qt-5/windows-deployment.html

### Creating a Windows Store app ###

1. Run

    qmake -tp vc neuronify.pro "CONFIG+=windeployqt"

2. Open the genereated project file in Visual Studio 2015.
3. Right click on the project and choose to upload using the options under Store.

### Creating a deployable .dmg on Mac

Simply run the following command in the build-directory:

    /path/to/Qt/installation/clang_64/bin/macdeployqt neuronify.app -qmldir=../neuronify -dmg

This should create a .dmg that can be used on machines without Qt installed.

### Building the documentation ###

You should first install the index files for Qt:

    sudo apt-get install qt5-doc qt5-doc-html qt5-default qt5-qmake qtquickcontrols5-doc-html qtlocation5-doc

Afterwards, run ./make-docs.sh in the doc folder to generate the documentation.
This will be generated in a folder named neuronify-docs above the source tree.
