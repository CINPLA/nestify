#ifndef POTASSIUMCURRENT_H
#define POTASSIUMCURRENT_H

#include "current.h"

class PotassiumCurrent : public Current
{
    Q_OBJECT
    Q_PROPERTY(double potassiumActivation READ potassiumActivation WRITE setPotassiumActivation NOTIFY potassiumActivationChanged)
    Q_PROPERTY(double meanPotassiumConductance READ meanPotassiumConductance WRITE setMeanPotassiumConductance NOTIFY meanPotassiumConductanceChanged)
    Q_PROPERTY(double potassiumPotential READ potassiumPotential WRITE setPotassiumPotential NOTIFY potassiumPotentialChanged)
    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)

public:
    PotassiumCurrent(QQuickItem *parent = 0);

    double potassiumActivation() const;
    double meanPotassiumConductance() const;
    double potassiumPotential() const;
    double voltage() const;

signals:
    void potassiumActivationChanged(double potassiumActivation);
    void meanPotassiumConductanceChanged(double meanPotassiumConductance);
    void potassiumPotentialChanged(double potassiumPotential);
    void voltageChanged(double voltage);

public slots:
    void setPotassiumActivation(double potassiumActivation);
    void setMeanPotassiumConductance(double meanPotassiumConductance);
    void setPotassiumPotential(double potassiumPotential);
    void setVoltage(double voltage);

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void resetPropertiesEvent() override;
    virtual void resetDynamicsEvent() override;

private:
    double m_potassiumActivation = 0.5;
    double m_meanPotassiumConductance = 36e-3;
    double m_potassiumPotential = -77e-3;
    double m_voltage = 0.0;
    double m_area;
};

#endif // POTASSIUMCURRENT_H
