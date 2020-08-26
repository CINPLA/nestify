#ifndef NEURONIFY_NEURONENGINE_H
#define NEURONIFY_NEURONENGINE_H

#include <QQuickItem>
#include <QQmlListProperty>

#include "../core/nodeengine.h"

class NeuronEngine : public NodeEngine
{
    Q_OBJECT

    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)
    Q_PROPERTY(double restingPotential READ restingPotential WRITE setRestingPotential NOTIFY restingPotentialChanged)
    Q_PROPERTY(double initialPotential READ initialPotential WRITE setInitialPotential NOTIFY initialPotentialChanged)
    Q_PROPERTY(double threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged)
    Q_PROPERTY(double capacitance READ capacitance WRITE setCapacitance NOTIFY capacitanceChanged)
    Q_PROPERTY(double minimumVoltage READ minimumVoltage WRITE setMinimumVoltage NOTIFY minimumVoltageChanged)
    Q_PROPERTY(double maximumVoltage READ maximumVoltage WRITE setMaximumVoltage NOTIFY maximumVoltageChanged)
    Q_PROPERTY(bool voltageClamped READ isVoltageClamped WRITE setVoltageClamped NOTIFY voltageClampedChanged)

public:
    NeuronEngine(QQuickItem *parent = 0);
    double voltage() const;
    double adaptionConductance() const;
    double restingPotential() const;
    double threshold() const;
    double capacitance() const;
    double initialPotential() const;
    double minimumVoltage() const;
    double maximumVoltage() const;
    bool isVoltageClamped() const;

public slots:
    void setVoltage(double arg);
    void setRestingPotential(double arg);
    void setThreshold(double threshold);
    void setCapacitance(double capacitance);
    void setInitialPotential(double initialPotential);
    void setMinimumVoltage(double minimumVoltage);
    void setMaximumVoltage(double maximumVoltage);
    void setVoltageClamped(bool voltageClamped);

signals:
    void voltageChanged(double arg);
    void restingPotentialChanged(double arg);
    void thresholdChanged(double threshold);
    void capacitanceChanged(double capacitance);
    void initialPotentialChanged(double initialPotential);
    void minimumVoltageChanged(double minimumVoltage);
    void maximumVoltageChanged(double maximumVoltage);
    void voltageClampedChanged(bool voltageClamped);

protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void fireEvent() override;
    virtual void receiveCurrentEvent(double currentOutput, NodeEngine *sender) override;
    virtual void resetPropertiesEvent() override;
    virtual void resetDynamicsEvent() override;

private:
    void checkFire();

    double m_voltage = 0.0;
    double m_restingPotential = -70.0e-3; // TODO remove from here?
    double m_initialPotential = -80.0e-3;
    double m_threshold = -55.0e-3;
    double m_capacitance = 0.2e-9;
    double m_receivedCurrents = 0.0;
    double m_minimumVoltage = -90.0e-3; // mV
    double m_maximumVoltage = 60.0e-3; // mV
    bool m_voltageClamped = true;
};

#endif // NEURONIFY_NEURONENGINE_H
