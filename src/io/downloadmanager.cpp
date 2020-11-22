#include "downloadmanager.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJSEngine>
#include <QJSValue>
#include <QJsonDocument>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QQmlFile>
#include <QSslError>
#include <QStandardPaths>
#include <QStringList>
#include <QTimer>
#include <QUrl>

bool saveToDisk(const QString &filename, QIODevice *data)
{
    QFile file(filename);
    if (!file.open(QIODevice::WriteOnly)) {
        qWarning() << "ERROR: Could not open for writing:" << filename;
        return false;
    }

    file.write(data->readAll());
    file.close();

    return true;
}

DownloadManager::DownloadManager() {}

void DownloadManager::upload(const QString &objectName, const QUrl localUrl, QJSValue callback)
{
    QString filename = QQmlFile::urlToLocalFileOrQrc(localUrl);
    QFile file(filename);
    file.open(QFile::ReadOnly);

    QByteArray data = file.readAll();

    uploadData(objectName, data, "image/png", [callback](const QString &result) mutable {
        callback.call(QJSValueList{QJSValue(result)});
    });
}

void DownloadManager::uploadText(const QString &objectName, const QString text, QJSValue callback)
{
    uploadData(objectName, text.toUtf8(), "plain/text", [callback](const QString &result) mutable {
        callback.call(QJSValueList{QJSValue(result)});
    });
}

void DownloadManager::uploadData(const QString &objectName,
                                 const QByteArray data,
                                 const QByteArray contentType,
                                 std::function<void(const QString &)> callback)
{
    QString urlString = QString("https://firebasestorage.googleapis.com/v0/b/") + m_storageBucket
                        + "/o?name=" + QUrl::toPercentEncoding(objectName);
    QUrl url(urlString);

    QNetworkRequest request(url);
    request.setRawHeader("Content-Type", contentType);
    request.setRawHeader("Authorization", QByteArray("Firebase ") + m_idToken.toLatin1());

    QNetworkReply *reply = m_networkAccessManager.post(request, data);

    connect(reply, &QNetworkReply::finished, [reply, callback]() mutable {
        QString result = QString::fromUtf8(reply->readAll());

        callback(result);

        reply->deleteLater();
    });
}

void DownloadManager::download(const QString &objectName,
                               const QUrl &localUrl,
                               std::function<void()> callback)
{
    qDebug() << "Storage bucket" << m_storageBucket;

    QString urlString = QString("https://firebasestorage.googleapis.com/v0/b/") + m_storageBucket
                        + "/o/" + QUrl::toPercentEncoding(objectName) + QString("?alt=media");
    QUrl url(urlString);

    if (!localUrl.isLocalFile()) {
        qWarning() << "ERROR: Requested download location is not local url:" << localUrl;
        return;
    }
    QString targetFilename = localUrl.toLocalFile();
    qDebug() << "Download requested" << urlString << targetFilename;
    QNetworkRequest request(url);
    request.setRawHeader("Authorization", QByteArray("Firebase ") + m_idToken.toLatin1());
    QNetworkReply *reply = m_networkAccessManager.get(request);
    connect(reply, &QNetworkReply::finished, [reply, targetFilename, callback]() mutable {
        QDir targetDir = QFileInfo(targetFilename).absoluteDir();
        if (!targetDir.mkpath(".")) {
            qDebug() << "ERROR: Could not create path" << targetDir;
            return;
        }
        QUrl url = reply->url();
        if (reply->error()) {
            qDebug() << "Download failed:" << url << reply->errorString();
            return;
        }

        if (!saveToDisk(targetFilename, reply)) {
            qDebug() << "Save to disk failed" << url;
            return;
        }

        callback();

        reply->deleteLater();
    });

#ifndef QT_NO_SSL
    connect(reply, &QNetworkReply::sslErrors, this, &DownloadManager::handleSslErrors);
#endif
}

void DownloadManager::download(const QString &objectName, const QUrl &localUrl, QJSValue callback)
{
    download(objectName, localUrl, [callback]() mutable { callback.call(); });
}

void DownloadManager::cachedDownload(const QString &objectName, QJSValue callback)
{
    QString fileName = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QString localObjectName = objectName;
    localObjectName.replace(QChar('/'), QDir::separator());
    fileName += QDir::separator() + localObjectName;
    QUrl localUrl = QUrl::fromLocalFile(fileName);
    download(objectName, localUrl, [localUrl, callback]() mutable {
        callback.call(QJSValueList{QJSValue{localUrl.toString()}});
    });
}

QString DownloadManager::idToken() const
{
    return m_idToken;
}

QString DownloadManager::databaseURL() const
{
    return m_databaseURL;
}

QString DownloadManager::authDomain() const
{
    return m_authDomain;
}

QString DownloadManager::projectId() const
{
    return m_projectId;
}

QString DownloadManager::storageBucket() const
{
    return m_storageBucket;
}

QString DownloadManager::messagingSenderId() const
{
    return m_messagingSenderId;
}

QString DownloadManager::apiKey() const
{
    return m_apiKey;
}

void DownloadManager::setIdToken(QString idToken)
{
    if (m_idToken == idToken)
        return;

    m_idToken = idToken;
    emit idTokenChanged(m_idToken);
}

void DownloadManager::setDatabaseURL(QString databaseURL)
{
    if (m_databaseURL == databaseURL)
        return;

    m_databaseURL = databaseURL;
    emit databaseURLChanged(m_databaseURL);
}

void DownloadManager::setAuthDomain(QString authDomain)
{
    if (m_authDomain == authDomain)
        return;

    m_authDomain = authDomain;
    emit authDomainChanged(m_authDomain);
}

void DownloadManager::setProjectId(QString projectId)
{
    if (m_projectId == projectId)
        return;

    m_projectId = projectId;
    emit projectIdChanged(m_projectId);
}

void DownloadManager::setStorageBucket(QString storageBucket)
{
    if (m_storageBucket == storageBucket)
        return;

    m_storageBucket = storageBucket;

    emit storageBucketChanged(m_storageBucket);
}

void DownloadManager::setMessagingSenderId(QString messagingSenderId)
{
    if (m_messagingSenderId == messagingSenderId)
        return;

    m_messagingSenderId = messagingSenderId;
    emit messagingSenderIdChanged(m_messagingSenderId);
}

void DownloadManager::setApiKey(QString apiKey)
{
    if (m_apiKey == apiKey)
        return;

    m_apiKey = apiKey;
    emit apiKeyChanged(m_apiKey);
}

#ifndef QT_NO_SSL
void DownloadManager::handleSslErrors(const QList<QSslError> &sslErrors)
{
    foreach (const QSslError &error, sslErrors)
        fprintf(stderr, "SSL error: %s\n", qPrintable(error.errorString()));
}
#endif

QString DownloadManager::buildUrl(const QString &name)
{
    auto url = m_databaseURL + "/" + name;
    if (!m_idToken.isEmpty()) {
        if (!name.contains("?")) {
            url += "?";
        } else {
            url += "&";
        }
        url += "auth=" + m_idToken;
    }
    return url;
}
