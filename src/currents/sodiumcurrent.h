#ifndef SODIUMCURRENT_H
#define SODIUMCURRENT_H

#include "current.h"

class SodiumCurrent : public Current
{
    Q_OBJECT
    // TODO consider removing these setters
    Q_PROPERTY(double sodiumActivation READ sodiumActivation WRITE setSodiumActivation NOTIFY sodiumActivationChanged)
    Q_PROPERTY(double sodiumInactivation READ sodiumInactivation WRITE setSodiumInactivation NOTIFY sodiumInactivationChanged)
    Q_PROPERTY(double meanSodiumConductance READ meanSodiumConductance WRITE setMeanSodiumConductance NOTIFY meanSodiumConductanceChanged)
    Q_PROPERTY(double sodiumPotential READ sodiumPotential WRITE setSodiumPotential NOTIFY sodiumPotentialChanged)
    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)

public:
    explicit SodiumCurrent(QQuickItem *parent = 0);

    double sodiumActivation() const;
    double sodiumInactivation() const;
    double meanSodiumConductance() const;
    double sodiumPotential() const;
    double voltage() const;

public slots:
    void setSodiumActivation(double sodiumActivation);
    void setSodiumInactivation(double sodiumInactivation);
    void setMeanSodiumConductance(double meanSodiumConductance);
    void setSodiumPotential(double sodiumPotential);
    void setVoltage(double voltage);

signals:
    void sodiumActivationChanged(double sodiumActivation);
    void sodiumInactivationChanged(double sodiumInactivation);
    void meanSodiumConductanceChanged(double meanSodiumConductance);
    void sodiumPotentialChanged(double sodiumPotential);
    void voltageChanged(double voltage);

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void resetPropertiesEvent() override;

private:
    double m_sodiumActivation = 0.5;
    double m_sodiumInactivation = 0.5;
    double m_meanSodiumConductance = 0.0;
    double m_sodiumPotential = 0.0;
    double m_voltage = 0.0;
    double m_area = 0.0;

protected:
    virtual void resetDynamicsEvent() override;
};

#endif // SODIUMCURRENT_H
