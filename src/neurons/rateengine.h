#ifndef RATEENGINE_H
#define RATEENGINE_H

#include "../core/nodeengine.h"

#include <QQuickItem>
#include <QQmlListProperty>
#include <vector>
#include "../utility/mathhelper.h"

using std::vector;

class RateEngine : public NodeEngine
{
    Q_OBJECT
    Q_PROPERTY(double firingRate READ firingRate WRITE setFiringRate NOTIFY firingRateChanged)
    Q_PROPERTY(double windowDuration READ windowDuration WRITE setWindowDuration NOTIFY windowDurationChanged)
    Q_PROPERTY(int neuronCount READ neuronCount WRITE setNeuronCount NOTIFY neuronCountChanged)
    Q_PROPERTY(double temporalResolution READ temporalResolution WRITE setTemporalResolution NOTIFY temporalResolutionChanged)

public:
    RateEngine(QQuickItem *parent = 0);

    double firingRate() const;
    double windowDuration() const;
    int neuronCount() const;
    double temporalResolution() const;

public slots:
    void addFireEvent();
    void setFiringRate(double firingRate);
    void setWindowDuration(double windowDuration);
    void setNeuronCount(int neuronCount);
    void setTemporalResolution(double temporalResolution);

signals:
    void firingRateChanged(double firingRate);
    void windowDurationChanged(double windowDuration);
    void neuronCountChanged(int neuronCount);
    void temporalResolutionChanged(double temporalResolution);

protected:
    virtual void resetPropertiesEvent() override;
    virtual void resetDynamicsEvent() override;

private:
    void computeFiringRate();

    vector<double> m_spikeTimes;
    int m_neuronCount = 0;
    double m_firingRate = 0.0;
    double m_time = 0.0;
    double m_windowDuration = 100e-3;
    double m_temporalResolution = 100e-3;

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
};

#endif // RATEENGINE_H
