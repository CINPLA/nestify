#ifndef ASYNCFILEDIALOG_H
#define ASYNCFILEDIALOG_H

#include <QObject>

class AsyncFileDialog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(
        QString filenameHint READ filenameHint WRITE setFilenameHint NOTIFY filenameHintChanged)

private:
    QString m_filenameHint;

public:
    explicit AsyncFileDialog(QObject *parent = nullptr);

    Q_INVOKABLE void getOpenFileContent();
    Q_INVOKABLE void saveFileContent(QString fileContents);
    QString filenameHint() const { return m_filenameHint; }

public slots:
    void setFilenameHint(QString filenameHint)
    {
        if (m_filenameHint == filenameHint)
            return;

        m_filenameHint = filenameHint;
        emit filenameHintChanged(m_filenameHint);
    }

signals:
    void contentRequested(const QString &filename, const QString &contents);
    void filenameHintChanged(QString filenameHint);
};

#endif // ASYNCFILEDIALOG_H
