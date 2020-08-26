#include "leakcurrent.h"

#include "../neurons/neuronengine.h"

/*!
 * \class LeakCurrent
 * \inmodule Neuronify
 * \ingroup neuronify-neurons
 * \brief The LeakCurrent class defines a current that drives the
 * \l NeuronEngine towards the defined resting membrane potential.
 */

LeakCurrent::LeakCurrent(QQuickItem *parent)
    : Current(parent)
{

}

LeakCurrent::~LeakCurrent()
{

}

double LeakCurrent::resistance() const
{
    return m_resistance;
}

double LeakCurrent::voltage() const
{
    return m_voltage;
}

double LeakCurrent::restingPotential() const
{
    return m_restingPotential;
}

void LeakCurrent::setVoltage(double voltage)
{
    if (qFuzzyCompare(m_voltage, voltage))
        return;

    m_voltage = voltage;
    emit voltageChanged(m_voltage);
}

void LeakCurrent::setRestingPotential(double restingPotential)
{
    if (qFuzzyCompare(m_restingPotential, restingPotential))
        return;

    m_restingPotential = restingPotential;
    emit restingPotentialChanged(m_restingPotential);
}

void LeakCurrent::setResistance(double resistance)
{
    if (qFuzzyCompare(m_resistance, resistance))
        return;

    m_resistance = resistance;
    emit resistanceChanged(m_resistance);
}

double leakCurrent(double restingPotential, double voltage, double resistance)
{
    double Em = restingPotential;
    double V = voltage;
    double R = resistance;

    return -1.0 / R * (V - Em);
}

void LeakCurrent::stepEvent(double dt, bool parentEnabled)
{
    // TODO remove this boilerplate so we don't have to implement it in every current

    Q_UNUSED(dt);
    if(!parentEnabled) {
        return;
    }

    // TODO create a new class/template that allow us to make new, functional currents
    setCurrent(leakCurrent(m_restingPotential, m_voltage, m_resistance));
}

void LeakCurrent::resetPropertiesEvent()
{
    Current::resetPropertiesEvent();
    setResistance(100.0e6);
}
