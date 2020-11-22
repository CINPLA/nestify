#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QUrl>
#include <QJSValue>

class QQmlEngine;

class FileIO : public QObject
{
    Q_OBJECT

public:
    explicit FileIO(QObject *parent = 0);

    Q_INVOKABLE static void read(const QUrl &fileUrl, QJSValue callback = QJSValue());
    Q_INVOKABLE static void write(const QUrl &fileUrl, const QString &data, QJSValue callback = QJSValue());
    Q_INVOKABLE static QString readSynchronously(const QUrl &fileUrl);
    Q_INVOKABLE static bool writeSynchronously(const QUrl &fileUrl, const QString &data);
    Q_INVOKABLE static bool exists(const QUrl &fileUrl);
    Q_INVOKABLE static void makePath(const QUrl &path, QJSValue callback);
    Q_INVOKABLE static bool makePathSynchronously(const QUrl &path);
    Q_INVOKABLE static void getOpenFileContent(QJSValue callback);

    static QObject *qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);
};

#endif // FILEIO_H
