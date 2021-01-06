#ifndef KERNEL_H
#define KERNEL_H

#include <QQuickItem>
#include <vector>
#include <iostream>
#include <QImage>
#include <iomanip>
#include <limits>

#include "kernels/abstractkernelengine.h"
#include "../core/neuronifyobject.h"

using std::vector;

class Kernel : public NeuronifyObject
{
    Q_OBJECT
    Q_PROPERTY(QImage spatialImage READ spatialImage WRITE setSpatialImage NOTIFY imageChanged)
    Q_PROPERTY(AbstractKernelEngine* abstractKernelEngineType READ abstractKernelEngineType WRITE setAbstractKernelEngineType NOTIFY abstractKernelEngineTypeChanged)
    Q_PROPERTY(int imageAlpha READ imageAlpha WRITE setImageAlpha NOTIFY imageAlphaChanged)

public:
    Kernel(QQuickItem *parent = 0);

public:
    int resolutionHeight() const;
    int resolutionWidth() const;
    int imageAlpha() const;


    vector<vector<double> > spatial();
    AbstractKernelEngine* abstractKernelEngineType() const;
    QImage spatialImage() const;

public slots:
    void setSpatialImage(QImage spatialImage);
    void setAbstractKernelEngineType(AbstractKernelEngine* abstractKernelEngineType);
    void recreate();
    void setImageAlpha(int imageAlpha);

signals:
    void imageChanged(QImage spatialImage);
    void abstractKernelEngineTypeChanged(AbstractKernelEngine* abstractKernelEngineType);


    void imageAlphaChanged(int imageAlpha);

private:
    AbstractKernelEngine* m_abstractKernelEngineType = nullptr;
    int m_imageAlpha = 225;

protected:
    vector< vector <double>> m_spatial;
    QImage m_spatialImage;

};


#endif // KERNEL_H
