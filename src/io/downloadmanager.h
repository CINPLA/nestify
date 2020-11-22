#ifndef DOWNLOADMANAGER_H
#define DOWNLOADMANAGER_H

#include <memory>
#include <QCoreApplication>
#include <QFile>
#include <QFileInfo>
#include <QJSValue>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QSignalMapper>
#ifndef QT_NO_SSL
#include <QSslError>
#endif
#include <QStringList>
#include <QTimer>
#include <QUrl>

struct DownloadData
{
    QString filename;
    QJSValue callback;
};

class DownloadManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString idToken READ idToken WRITE setIdToken NOTIFY idTokenChanged)
    Q_PROPERTY(QString databaseURL READ databaseURL WRITE setDatabaseURL NOTIFY databaseURLChanged)
    Q_PROPERTY(QString authDomain READ authDomain WRITE setAuthDomain NOTIFY authDomainChanged)
    Q_PROPERTY(QString projectId READ projectId WRITE setProjectId NOTIFY projectIdChanged)
    Q_PROPERTY(
        QString storageBucket READ storageBucket WRITE setStorageBucket NOTIFY storageBucketChanged)
    Q_PROPERTY(QString messagingSenderId READ messagingSenderId WRITE setMessagingSenderId NOTIFY
                   messagingSenderIdChanged)
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY apiKeyChanged)

public:
    DownloadManager();
    Q_INVOKABLE void download(const QString &objectName, const QUrl &localUrl, QJSValue callback);
    Q_INVOKABLE void cachedDownload(const QString &objectName, QJSValue callback);
    Q_INVOKABLE void upload(const QString &objectName, const QUrl localUrl, QJSValue callback);
    Q_INVOKABLE void uploadText(const QString &objectName, const QString text, QJSValue callback);
    void uploadData(const QString &objectName,
                    const QByteArray data,
                    const QByteArray contentType,
                    std::function<void(const QString &)> callback);
    void download(const QString &objectName,
                  const QUrl &localUrl,
                  std::function<void(void)> callback);

    Q_INVOKABLE QString buildUrl(const QString &name);

    QString idToken() const;
    QString databaseURL() const;
    QString authDomain() const;
    QString projectId() const;
    QString storageBucket() const;
    QString messagingSenderId() const;
    QString apiKey() const;

public slots:
    void setIdToken(QString idToken);
    void setDatabaseURL(QString databaseURL);
    void setAuthDomain(QString authDomain);
    void setProjectId(QString projectId);
    void setStorageBucket(QString storageBucket);
    void setMessagingSenderId(QString messagingSenderId);
    void setApiKey(QString apiKey);

signals:
    void idTokenChanged(QString idToken);
    void databaseURLChanged(QString databaseURL);
    void authDomainChanged(QString authDomain);
    void projectIdChanged(QString projectId);
    void storageBucketChanged(QString storageBucket);
    void messagingSenderIdChanged(QString messagingSenderId);
    void apiKeyChanged(QString apiKey);

private slots:
#ifndef QT_NO_SSL
    void handleSslErrors(const QList<QSslError> &errors);
#endif

private:
    QNetworkAccessManager m_downloadManager;
    QNetworkAccessManager m_uploadManager;
    QNetworkAccessManager m_networkAccessManager;
    QMap<QNetworkReply *, DownloadData> currentDownloads;
    QMap<QNetworkReply *, QJSValue> currentUploads;
    QString m_idToken;
    QString m_databaseURL;
    QString m_authDomain;
    QString m_projectId;
    QString m_storageBucket;
    QString m_messagingSenderId;
    QString m_apiKey;
};

#endif // DOWNLOADMANAGER_H
