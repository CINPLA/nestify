#include "compartmentengine.h"

#include <QtMath>

#include "../currents/current.h"

CompartmentEngine::CompartmentEngine()
{

}

double CompartmentEngine::voltage() const
{
    return m_voltage;
}

double CompartmentEngine::capacitance() const
{
    return m_capacitance;
}

double CompartmentEngine::length() const
{
    return m_length;
}

double CompartmentEngine::radiusA() const
{
    return m_radiusA;
}

double CompartmentEngine::radiusB() const
{
    return m_radiusB;
}

double CompartmentEngine::area() const
{
    return m_area;
}

void CompartmentEngine::setVoltage(double voltage)
{
    if (qFuzzyCompare(m_voltage, voltage))
        return;

    m_voltage = voltage;
    emit voltageChanged(m_voltage);
}

void CompartmentEngine::setCapacitance(double capacitance)
{
    if (qFuzzyCompare(m_capacitance, capacitance))
        return;

    m_capacitance = capacitance;
    emit capacitanceChanged(m_capacitance);
}

void CompartmentEngine::setLength(double length)
{
    if (qFuzzyCompare(m_length, length))
        return;

    m_length = length;
    updateArea();
    emit lengthChanged(m_length);
}

void CompartmentEngine::setRadiusA(double radiusA)
{
    if (qFuzzyCompare(m_radiusA, radiusA))
        return;

    m_radiusA = radiusA;
    updateArea();
    emit radiusAChanged(m_radiusA);
}

void CompartmentEngine::setRadiusB(double radiusB)
{
    if (qFuzzyCompare(m_radiusB, radiusB))
        return;

    m_radiusB = radiusB;
    updateArea();
    emit radiusBChanged(m_radiusB);
}


void CompartmentEngine::resetDynamicsEvent()
{
    setVoltage(-60e-3);
    m_receivedCurrents = 0.0;
}

void CompartmentEngine::resetPropertiesEvent()
{
    setLength(50e-6);
    setRadiusA(50e-6);
    setRadiusB(50e-6);
}

void CompartmentEngine::stepEvent(double dt, bool parentEnabled)
{
    if(!parentEnabled) {
        return;
    }

    double otherCurrents = 0.0;

    // TODO do this only when children have changed
    for(Current* current : findChildren<Current*>()) {
        if(current->isEnabled()) {
            otherCurrents += current->current();
        }
    }

    double totalCurrent = otherCurrents + m_receivedCurrents;
    double dV = totalCurrent / m_capacitance * dt;
    m_voltage += dV;

    emit voltageChanged(m_voltage);

    m_receivedCurrents = 0.0;
}

void CompartmentEngine::receiveCurrentEvent(double currentOutput, NodeEngine *sender)
{
    Q_UNUSED(sender);
    if(!isEnabled()) {
        return;
    }
    m_receivedCurrents += currentOutput;
}

void CompartmentEngine::updateArea()
{
    double h = m_length;
    double r1 = m_radiusA;
    double r2 = m_radiusB;
    double rd = r1 - r2;

    m_area = M_PI * ((r1 + r2) * sqrt(rd*rd + h*h) + r1*r1 + r2*r2);
    emit areaChanged(m_area);
}
