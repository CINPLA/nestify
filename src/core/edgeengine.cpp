#include "edgeengine.h"
#include "nodeengine.h"

EdgeEngine::EdgeEngine(QQuickItem *parent)
    : NeuronifyObject(parent)
{

}

double EdgeEngine::currentOutput() const
{
    return m_currentOutput;
}

double EdgeEngine::currentInput() const
{
    return m_currentInput;
}

void EdgeEngine::stepEvent(double dt, bool parentEnabled)
{
    Q_UNUSED(dt)
    Q_UNUSED(parentEnabled)
}

void EdgeEngine::receiveFireEvent(NodeEngine *sender)
{
    Q_UNUSED(sender);
}


void EdgeEngine::receiveFire(NodeEngine *sender)
{
    for(EdgeEngine* child : findChildren<EdgeEngine*>()) {
        child->receiveFire(sender);
    }
    receiveFireEvent(sender);
    emit receivedFire(sender);
}

void EdgeEngine::setCurrentInput(double currentInput)
{
    if (qFuzzyCompare(m_currentInput, currentInput))
        return;

    m_currentInput = currentInput;
    emit currentInputChanged(m_currentInput);
}

void EdgeEngine::step(double dt, bool parentEnabled)
{
    bool enable = isEnabled() && parentEnabled;
    for(EdgeEngine* child : findChildren<EdgeEngine*>()) {
        child->step(dt, enable);
    }
    stepEvent(dt, enable);
    emit stepped(dt, enable);
}

void EdgeEngine::setCurrentOutput(double currentOutput)
{
    if (m_currentOutput == currentOutput)
        return;

    m_currentOutput = currentOutput;
    emit currentOutputChanged(currentOutput);
}

