#include "neuronengine.h"

#include <QDebug>
#include <cmath>

#include "../currents/current.h"

using namespace std;

/*!
 * \class NeuronEngine
 * \inmodule Neuronify
 * \ingroup neuronify-neurons
 * \brief The NeuronEngine class is a common engine used by most neurons.
 *
 * Neurons have common properties such as the resting membrane potential,
 * possible synaptic input and a voltage.
 * Currents are responsible for changes to the voltage.
 *
 * \l NodeEngine holds a list of all children added in QML.
 * In stepEvent() all the children are iterated, and if they contain a
 * \l Current object, the Current::current() function is called to obtain
 * the current value of the given current.
 * The \l Current class can be subclassed in C++ or QML to define different
 * types of currents, such as \l LeakCurrent and \l AdaptationCurrent.
 */

NeuronEngine::NeuronEngine(QQuickItem *parent)
    : NodeEngine(parent)
{
}

double NeuronEngine::voltage() const
{
    return m_voltage;
}


double NeuronEngine::restingPotential() const
{
    return m_restingPotential;
}


double NeuronEngine::threshold() const
{
    return m_threshold;
}

double NeuronEngine::capacitance() const
{
    return m_capacitance;
}

double NeuronEngine::initialPotential() const
{
    return m_initialPotential;
}

double NeuronEngine::minimumVoltage() const
{
    return m_minimumVoltage;
}

double NeuronEngine::maximumVoltage() const
{
    return m_maximumVoltage;
}

bool NeuronEngine::isVoltageClamped() const
{
    return m_voltageClamped;
}

void NeuronEngine::resetDynamicsEvent()
{
    setVoltage(m_initialPotential);
    m_receivedCurrents = 0.0;
}

void NeuronEngine::setVoltage(double arg)
{
    if (m_voltage != arg) {
        m_voltage = arg;
        emit voltageChanged(arg);
    }
}

void NeuronEngine::stepEvent(double dt, bool parentEnabled)
{
    if(!parentEnabled) {
        return;
    }

    checkFire();

    // TODO do this only when children added/removed?
    double otherCurrents = 0.0;
    for(Current* current : findChildren<Current*>()) {
        if(current->isEnabled()) {
            otherCurrents += current->current();
        }
    }



    double totalCurrent = otherCurrents + m_receivedCurrents;
    double dV = totalCurrent / m_capacitance * dt;
    m_voltage += dV;

    if(m_voltageClamped) {
        m_voltage = max(m_minimumVoltage, min(m_maximumVoltage, m_voltage));
    }


    emit voltageChanged(m_voltage);

    m_receivedCurrents = 0.0;
}

void NeuronEngine::fireEvent()
{
    setVoltage(m_initialPotential);
}

void NeuronEngine::receiveCurrentEvent(double currentOutput, NodeEngine *sender)
{
    Q_UNUSED(sender);
    // TODO Do this in GraphEngine?
    if(!isEnabled()) {
        return;
    }
    m_receivedCurrents += currentOutput;
}

void NeuronEngine::resetPropertiesEvent()
{
    setRestingPotential(-70.0e-3);
    setInitialPotential(-80.0e-3);
    setThreshold(-55.0e-3);
    setCapacitance(0.2e-9);
}


void NeuronEngine::setRestingPotential(double arg)
{
    if (m_restingPotential != arg) {
        m_restingPotential = arg;
        emit restingPotentialChanged(arg);
    }
}


void NeuronEngine::setThreshold(double threshold)
{
    if (m_threshold == threshold)
        return;

    m_threshold = threshold;
    emit thresholdChanged(threshold);
}

void NeuronEngine::setCapacitance(double capacitance)
{
    if (m_capacitance == capacitance)
        return;

    m_capacitance = capacitance;
    emit capacitanceChanged(capacitance);
}

void NeuronEngine::setInitialPotential(double postFirePotential)
{
    if (m_initialPotential == postFirePotential)
        return;

    m_initialPotential = postFirePotential;
    emit initialPotentialChanged(postFirePotential);
}

void NeuronEngine::setMinimumVoltage(double minimumVoltage)
{
    if (m_minimumVoltage == minimumVoltage)
        return;

    m_minimumVoltage = minimumVoltage;
    emit minimumVoltageChanged(minimumVoltage);
}

void NeuronEngine::setMaximumVoltage(double maximumVoltage)
{
    if (m_maximumVoltage == maximumVoltage)
        return;

    m_maximumVoltage = maximumVoltage;
    emit maximumVoltageChanged(maximumVoltage);
}

void NeuronEngine::setVoltageClamped(bool voltageClamped)
{
    if (m_voltageClamped == voltageClamped)
        return;

    m_voltageClamped = voltageClamped;
    emit voltageClampedChanged(voltageClamped);
}


void NeuronEngine::checkFire()
{
    if(m_voltage > m_threshold) {
        fire();
    }
}
