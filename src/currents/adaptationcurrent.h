#ifndef ADAPTATIONCURRENT_H
#define ADAPTATIONCURRENT_H

#include "current.h"

class AdaptationCurrent : public Current
{
    Q_OBJECT
    Q_PROPERTY(double adaptation READ adaptation WRITE setAdaptation NOTIFY adaptationChanged)
    Q_PROPERTY(double conductance READ conductance NOTIFY conductanceChanged)
    Q_PROPERTY(double timeConstant READ timeConstant WRITE setTimeConstant NOTIFY timeConstantChanged)
    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)
    Q_PROPERTY(double restingPotential READ restingPotential WRITE setRestingPotential NOTIFY restingPotentialChanged)

public:
    explicit AdaptationCurrent(QQuickItem *parent = 0);
    ~AdaptationCurrent();

    double adaptation() const;
    double conductance() const;
    double timeConstant() const;

    double voltage() const;

    double restingPotential() const;

signals:
    void adaptationChanged(double arg);
    void conductanceChanged(double arg);
    void timeConstantChanged(double arg);

    void voltageChanged(double voltage);

    void restingPotentialChanged(double restingPotential);

public slots:
    void setAdaptation(double arg);
    void setConductance(double arg);
    void setTimeConstant(double arg);

    void setVoltage(double voltage);

    void setRestingPotential(double restingPotential);

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void fireEvent() override;
    virtual void resetPropertiesEvent() override;
    virtual void resetDynamicsEvent() override;

private:
    double m_adaptation = 0.0;
    double m_conductance = 0.0;
    double m_timeConstant = 0.0;
    double m_voltage;
    double m_restingPotential;
};

#endif // ADAPTATIONCURRENT_H
