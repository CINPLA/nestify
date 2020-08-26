#include "current.h"

/*!
 * \class Current
 * \inmodule Neuronify
 * \ingroup neuronify-neurons
 * \brief The Current class defines the currents used by \l NeuronEngine.
 *
 * Other classes may subclass \l Current to define a specific current.
 * The subclassed object must be added as a child to a \l NeuronEngine.
 * As all other children of a \l NodeEngine object it will receive step()
 * and fire() events whenever the parent \l NodeEngine object (in this case
 * a \l NeuronEngine) receives the respective events.
 *
 * The \l Current subclass may then alter its \l current property which
 * will be read and added to the sum of other currents by \l NeuronEngine.
 */

Current::Current(QQuickItem *parent)
    : NodeEngine(parent)
{
}

Current::~Current()
{
}

double Current::current() const
{
    return m_current;
}

void Current::setCurrent(double arg)
{
    if (m_current == arg)
        return;

    m_current = arg;
    emit currentChanged(arg);
}

void Current::resetPropertiesEvent()
{
    m_current = 0.0;
}

