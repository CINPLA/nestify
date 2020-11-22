#include "asyncfiledialog.h"

#include <QDebug>
#include <QFileDialog>

AsyncFileDialog::AsyncFileDialog(QObject *parent) : QObject(parent)
{

}

void AsyncFileDialog::getOpenFileContent()
{
    qDebug() << "Opening file dialog";
    auto fileReady = [this](const QString &filename, const QByteArray &fileContents) {
        qDebug() << "Opening file" << filename;
        contentRequested(filename, QString(fileContents));
    };
    QFileDialog::getOpenFileContent("*.*", fileReady);
}

void AsyncFileDialog::saveFileContent(QString fileContents)
{
    qDebug() << "Opening save dialog";
    QFileDialog::saveFileContent(fileContents.toUtf8(), "simulation.nfy");
}
