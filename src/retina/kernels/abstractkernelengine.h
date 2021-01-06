#ifndef KERNELABSTRACTENGINE_H
#define KERNELABSTRACTENGINE_H

#include <QQuickItem>
#include <vector>
#include <iostream>
#include "../../core/neuronifyobject.h"
#include "../../utility/mathhelper.h"

using std::vector;

class AbstractKernelEngine: public NeuronifyObject
{
    Q_OBJECT
    Q_PROPERTY(int resolutionHeight READ resolutionHeight WRITE setResolutionHeight NOTIFY resolutionHeightChanged)
    Q_PROPERTY(int resolutionWidth READ resolutionWidth WRITE setResolutionWidth NOTIFY resolutionWidthChanged)
    Q_PROPERTY(double xOffset READ xOffset WRITE setXOffset NOTIFY xOffsetChanged)
    Q_PROPERTY(double yOffset READ yOffset WRITE setYOffset NOTIFY yOffsetChanged)


public:
    AbstractKernelEngine();

    virtual void createKernel(vector<vector<double> > * spatial) = 0;
    int resolutionHeight() const;
    int resolutionWidth() const;

    vector<double> x() const;
    vector<double> y() const;

    double xOffset() const;
    double yOffset() const;

public slots:
    void setResolutionHeight(int resolutionHeight);
    void setResolutionWidth(int resolutionWidth);

    void setXOffset(double xOffset);
    void setYOffset(double yOffset);

signals:
    void resolutionHeightChanged(int resolutionHeight);
    void resolutionWidthChanged(int resolutionWidth);
    void needsRecreation();
    void xOffsetChanged(double xOffset);
    void yOffsetChanged(double yOffset);

protected:
    int m_resolutionHeight=20;
    int m_resolutionWidth=20;
    vector<double> m_x;
    vector<double> m_y;
    double m_xOffset;
    double m_yOffset;

private:
    void updateX();
    void updateY();
};

#endif // KERNELABSTRACTENGINE_H
