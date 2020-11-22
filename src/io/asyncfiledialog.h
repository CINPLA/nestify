#ifndef ASYNCFILEDIALOG_H
#define ASYNCFILEDIALOG_H

#include <QObject>

class AsyncFileDialog : public QObject
{
    Q_OBJECT

public:
    explicit AsyncFileDialog(QObject *parent = nullptr);

    Q_INVOKABLE void getOpenFileContent();
    Q_INVOKABLE void saveFileContent(QString fileContents);
signals:
    void contentRequested(const QString &filename, const QString &contents);

};

#endif // ASYNCFILEDIALOG_H
