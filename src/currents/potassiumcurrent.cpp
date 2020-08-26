#include "potassiumcurrent.h"

#include <QtMath>

#include "../neurons/neuronengine.h"

PotassiumCurrent::PotassiumCurrent(QQuickItem *parent) :
    Current(parent)
{

}

double PotassiumCurrent::potassiumActivation() const
{
    return m_potassiumActivation;
}

double PotassiumCurrent::meanPotassiumConductance() const
{
    return m_meanPotassiumConductance;
}

double PotassiumCurrent::potassiumPotential() const
{
    return m_potassiumPotential;
}

double PotassiumCurrent::voltage() const
{
    return m_voltage;
}

void PotassiumCurrent::setPotassiumActivation(double potassiumActivation)
{
    if (qFuzzyCompare(m_potassiumActivation, potassiumActivation))
        return;

    m_potassiumActivation = potassiumActivation;
    emit potassiumActivationChanged(m_potassiumActivation);
}

void PotassiumCurrent::setMeanPotassiumConductance(double meanPotassiumConductance)
{
    if (qFuzzyCompare(m_meanPotassiumConductance, meanPotassiumConductance))
        return;

    m_meanPotassiumConductance = meanPotassiumConductance;
    emit meanPotassiumConductanceChanged(m_meanPotassiumConductance);
}

void PotassiumCurrent::setPotassiumPotential(double potassiumPotential)
{
    if (qFuzzyCompare(m_potassiumPotential, potassiumPotential))
        return;

    m_potassiumPotential = potassiumPotential;
    emit potassiumPotentialChanged(m_potassiumPotential);
}

void PotassiumCurrent::setVoltage(double voltage)
{
    if (qFuzzyCompare(m_voltage, voltage))
        return;

    m_voltage = voltage;
    emit voltageChanged(m_voltage);
}

void PotassiumCurrent::stepEvent(double dt, bool parentEnabled)
{
    // TODO remove this boilerplate so we don't have to implement it in every current
    Q_UNUSED(dt);
    if(!parentEnabled) {
        return;
    }

    double V = m_voltage * 1e3;

    double potassiumActivationAlpha = 0.01 * ((V + 55) / (1.0 - exp(-(V + 55) / 10.0)));
    double potassiumActivationBeta = 0.125 * exp(- (V + 65) / 80);

    double n = m_potassiumActivation;
    double alphan = potassiumActivationAlpha;
    double betan = potassiumActivationBeta;
    double dn = 1e3 * dt * (alphan * (1 - n) - betan * n);

    n += dn;
    n = fmax(0.0, fmin(1.0, n));

    double gK = m_meanPotassiumConductance;
    double EK = m_potassiumPotential;
    double n4 = n*n*n*n;

    setCurrent(-gK * n4 * (m_voltage - EK));

    m_potassiumActivation = n;
}

void PotassiumCurrent::resetPropertiesEvent()
{
    Current::resetPropertiesEvent();
    setMeanPotassiumConductance(36e-3);
    setPotassiumPotential(-77e-3);
}


void PotassiumCurrent::resetDynamicsEvent()
{
    Current::resetDynamicsEvent();
    setPotassiumActivation(0.31);
    setVoltage(0.0);
}
