#include "adaptationcurrent.h"

/*!
 * \class AdaptationCurrent
 * \inmodule Neuronify
 * \ingroup neuronify-neurons
 * \brief The AdaptationCurrent class produces a current that drives the
 * voltage towards the membrane potential and increases each time the neuron
 * fires.
 */

AdaptationCurrent::AdaptationCurrent(QQuickItem *parent)
    : Current(parent)
{

}

AdaptationCurrent::~AdaptationCurrent()
{

}

double AdaptationCurrent::adaptation() const
{
    return m_adaptation;
}

double AdaptationCurrent::conductance() const
{
    return m_conductance;
}

double AdaptationCurrent::timeConstant() const
{
    return m_timeConstant;
}

double AdaptationCurrent::voltage() const
{
    return m_voltage;
}

double AdaptationCurrent::restingPotential() const
{
    return m_restingPotential;
}

void AdaptationCurrent::setAdaptation(double arg)
{
    if (m_adaptation == arg)
        return;

    m_adaptation = arg;
    emit adaptationChanged(arg);
}

void AdaptationCurrent::setConductance(double arg)
{
    if (m_conductance == arg)
        return;

    m_conductance = arg;
    emit conductanceChanged(arg);
}

void AdaptationCurrent::setTimeConstant(double arg)
{
    if (m_timeConstant == arg)
        return;

    m_timeConstant = arg;
    emit timeConstantChanged(arg);
}

void AdaptationCurrent::setVoltage(double voltage)
{
    if (qFuzzyCompare(m_voltage, voltage))
        return;

    m_voltage = voltage;
    emit voltageChanged(m_voltage);
}

void AdaptationCurrent::setRestingPotential(double restingPotential)
{
    if (qFuzzyCompare(m_restingPotential, restingPotential))
        return;

    m_restingPotential = restingPotential;
    emit restingPotentialChanged(m_restingPotential);
}

void AdaptationCurrent::stepEvent(double dt, bool parentEnabled)
{
    Q_UNUSED(dt);
    if(!parentEnabled) {
        return;
    }

    double Em = m_restingPotential;
    double V = m_voltage;
    double g = m_conductance;
    double tau = m_timeConstant;

    g = g - g/tau * dt;

    double I = -g * (V - Em);

    setConductance(g);
    setTimeConstant(tau);
    setCurrent(I);
}

void AdaptationCurrent::fireEvent()
{
    m_conductance += m_adaptation;
}

void AdaptationCurrent::resetPropertiesEvent()
{
    m_adaptation = 10.0e-9;
    m_timeConstant = 500.0e-3;
}

void AdaptationCurrent::resetDynamicsEvent()
{
    m_conductance = 0.0;
}

