#ifndef NEURONIFYOBJECT_H
#define NEURONIFYOBJECT_H

#include <QObject>
#include <QQmlListProperty>
#include <QQuickItem>

#include "../io/propertygroup.h"

class NeuronifyObject : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<PropertyGroup> savedProperties READ savedProperties)

public:
    explicit NeuronifyObject(QQuickItem *parent = 0);

    QQmlListProperty<PropertyGroup> savedProperties();

    void addSavedPropertyGroup(PropertyGroup *propertyGroup);

signals:
    void resettedDynamics();
    void resettedProperties();

public slots:
    void resetDynamics();
    void resetProperties();

protected:
    virtual void resetDynamicsEvent();
    virtual void resetPropertiesEvent();

private:
    QList<PropertyGroup*> m_savedProperties;
};

#endif // NEURONIFYOBJECT_H
