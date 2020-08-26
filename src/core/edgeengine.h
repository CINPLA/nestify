#ifndef EDGEENGINE_H
#define EDGEENGINE_H

#include <QQuickItem>

#include "neuronifyobject.h"

class NodeEngine;

class EdgeEngine : public NeuronifyObject
{
    Q_OBJECT
    Q_PROPERTY(double currentOutput READ currentOutput WRITE setCurrentOutput NOTIFY currentOutputChanged)
    Q_PROPERTY(double currentInput READ currentInput WRITE setCurrentInput NOTIFY currentInputChanged)

public:
    explicit EdgeEngine(QQuickItem *parent = 0);

    double currentOutput() const;

    double currentInput() const;

signals:
    void stepped(double dt, bool parentEnabled);
    void currentOutputChanged(double currentOutput);
    void receivedFire(NodeEngine *sender);

    void currentInputChanged(double currentInput);

public slots:
    void step(double dt, bool parentEnabled);
    void setCurrentOutput(double currentOutput);
    void receiveFire(NodeEngine *sender);

    void setCurrentInput(double currentInput);

protected:
    virtual void stepEvent(double dt, bool parentEnabled);
    virtual void receiveFireEvent(NodeEngine *sender);

private:
    double m_currentOutput = 0.;
    double m_currentInput = 0.;
};

#endif // EDGEENGINE_H
