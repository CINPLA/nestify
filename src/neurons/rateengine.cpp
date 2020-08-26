#include "rateengine.h"

#include <QDebug>
#include <cmath>

#include "../currents/current.h"

using namespace std;

/*!
 * \class RateEngine
 * \inmodule Neuronify
 * \ingroup neuronify-neurons
 * \brief The RateEngine class is a common engine used RatePlot.
 */


RateEngine::RateEngine(QQuickItem *parent)
    : NodeEngine(parent)
{
}

void RateEngine::computeFiringRate()
{
    double value = 0.0;
    for(int j= m_spikeTimes.size(); j > 0; j--){
        double tau = m_time - m_spikeTimes[j-1];
        if(tau < m_windowDuration){
            value += 1./(sqrt(2*m_temporalResolution*m_temporalResolution))
                    *exp(-tau*tau/2./m_temporalResolution/m_temporalResolution);
        }else{
            m_spikeTimes.erase(m_spikeTimes.begin(), m_spikeTimes.begin()+1);

            break;
        }
    }
    m_firingRate = value/m_neuronCount;
    emit firingRateChanged(m_firingRate);
}


void RateEngine::stepEvent(double dt, bool parentEnabled)
{
    m_time += dt;
    if(!parentEnabled) {
        return;
    }
    if(m_neuronCount < 1){
        return;
    }
    computeFiringRate();
}


double RateEngine::firingRate() const
{
    return m_firingRate;
}

double RateEngine::windowDuration() const
{
    return m_windowDuration;
}

int RateEngine::neuronCount() const
{
    return m_neuronCount;
}

double RateEngine::temporalResolution() const
{
    return m_temporalResolution;
}

void RateEngine::addFireEvent()
{
    m_spikeTimes.push_back(m_time);
}

void RateEngine::setFiringRate(double firingRate)
{
    if (m_firingRate == firingRate)
        return;

    m_firingRate = firingRate;
    emit firingRateChanged(firingRate);
}

void RateEngine::setWindowDuration(double windowDuration)
{
    if (m_windowDuration == windowDuration)
        return;

    m_windowDuration = windowDuration;
    emit windowDurationChanged(windowDuration);
}

void RateEngine::setNeuronCount(int neuronCount)
{
    if (m_neuronCount == neuronCount)
        return;

    m_neuronCount = neuronCount;
    emit neuronCountChanged(neuronCount);
}

void RateEngine::setTemporalResolution(double temporalResolution)
{
    if (m_temporalResolution == temporalResolution)
        return;

    m_temporalResolution = temporalResolution;
    emit temporalResolutionChanged(temporalResolution);
}

void RateEngine::resetPropertiesEvent()
{
    setWindowDuration(300e-3);
    setTemporalResolution(200e-3);
}

void RateEngine::resetDynamicsEvent()
{
    m_firingRate = 0.0;
    m_spikeTimes.clear();
}

