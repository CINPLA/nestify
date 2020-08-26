#ifndef PASSIVECURRENT_H
#define PASSIVECURRENT_H

#include "current.h"

class LeakCurrent : public Current
{
    Q_OBJECT
    Q_PROPERTY(double resistance READ resistance WRITE setResistance NOTIFY resistanceChanged)
    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)
    Q_PROPERTY(double restingPotential READ restingPotential WRITE setRestingPotential NOTIFY restingPotentialChanged)

public:
    explicit LeakCurrent(QQuickItem *parent = 0);
    ~LeakCurrent();

    double resistance() const;

    double voltage() const;

    double restingPotential() const;

signals:
    void resistanceChanged(double arg);

    void voltageChanged(double voltage);

    void restingPotentialChanged(double restingPotential);

public slots:

    void setVoltage(double voltage);

    void setRestingPotential(double restingPotential);

    void setResistance(double resistance);

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void resetPropertiesEvent() override;

private:
    double m_resistance = 0.0;
    double m_voltage;
    double m_restingPotential;
};

#endif // PASSIVECURRENT_H
