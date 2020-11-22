
#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QQmlFile>
#include <QDir>
#include <QJSValue>
#include <QQmlEngine>
#include <QFileDialog>

/*!
 * \class FileIO
 * \inmodule Neuronify
 * \ingroup neuronify-utils
 * \brief FileIO is a helper class used for reading and writing files from QML.
 *
 * This is mainly used to read and save simulation files.
 */

FileIO::FileIO(QObject *parent) :
    QObject(parent)
{
}

void FileIO::read(const QUrl& fileUrl, QJSValue callback)
{
    QString data = readSynchronously(fileUrl);
    if(!callback.isCallable()) {
        return;
    }
    callback.call(QJSValueList{QJSValue(data)});
}

QString FileIO::readSynchronously(const QUrl& fileUrl)
{
    if (!fileUrl.isValid()){
        qWarning() <<  "ERROR: File url is invalid:" << fileUrl;
        return QString();
    }

    QString path = QQmlFile::urlToLocalFileOrQrc(fileUrl);

    QFile file(path);
    QString fileContent;
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "ERROR: Could not open file" << fileUrl;
        return QString();
    }
    return QString::fromUtf8(file.readAll());
}

void FileIO::write(const QUrl& fileUrl, const QString& data, QJSValue callback)
{
    bool result = writeSynchronously(fileUrl, data);
    if(!callback.isCallable()) {
        return;
    }
    callback.call(QJSValueList{QJSValue(result)});
}

bool FileIO::writeSynchronously(const QUrl& fileUrl, const QString& data)
{
    if (!fileUrl.isValid()){
        qWarning() <<  "ERROR: File url is invalid:" << fileUrl;
        return false;
    }
    QString path = QQmlFile::urlToLocalFileOrQrc(fileUrl);
    QFileInfo fileinfo(path);
    QDir directory = fileinfo.absoluteDir();
    if(!directory.exists() && !directory.mkpath(".")) {
        qDebug() << "Cannot make path to file" << fileUrl;
        return false;
    }
    QFile file(path);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)){
        qDebug() << "Couldn't open file" << path;
        return false;
    }

    file.write(data.toUtf8());
    file.close();

    return true;
}

void FileIO::makePath(const QUrl &path, QJSValue callback)
{
    bool result = makePathSynchronously(path);
    if(callback.isCallable()) {
        callback.call(QJSValueList{QJSValue(result)});
    }
}

bool FileIO::makePathSynchronously(const QUrl &path)
{
    if(!path.isLocalFile()) {
        qWarning() << "ERROR: Path is not local file:" << path;
        return false;
    }
    return QDir().mkpath(path.toLocalFile());
}

bool FileIO::exists(const QUrl &fileUrl)
{
    if(!fileUrl.isLocalFile()) {
        return false;
    }
    return QFileInfo(fileUrl.toLocalFile()).exists();
}

void FileIO::getOpenFileContent(QJSValue callback) {
    qDebug() << "Requesting open file contents" << callback.isCallable();
    auto fileReady = [&callback](const QString &filename, const QByteArray &fileContents) {
        qDebug() << "READY" << filename << fileContents << callback.isCallable();
        if(!callback.isCallable()) {
            return;
        }
        callback.call(QJSValueList{QJSValue(filename), QJSValue(QString(fileContents))});
    };
    QFileDialog::getOpenFileContent("*.*", fileReady);
}

QObject* FileIO::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine);
    Q_UNUSED(scriptEngine);

    return new FileIO;
}
