#ifndef COMPARTMENTENGINE_H
#define COMPARTMENTENGINE_H

#include "../core/nodeengine.h"


class CompartmentEngine : public NodeEngine
{
    Q_OBJECT

    Q_PROPERTY(double voltage READ voltage WRITE setVoltage NOTIFY voltageChanged)
    Q_PROPERTY(double capacitance READ capacitance WRITE setCapacitance NOTIFY capacitanceChanged)
    Q_PROPERTY(double length READ length WRITE setLength NOTIFY lengthChanged)
    Q_PROPERTY(double radiusA READ radiusA WRITE setRadiusA NOTIFY radiusAChanged)
    Q_PROPERTY(double radiusB READ radiusB WRITE setRadiusB NOTIFY radiusBChanged)
    Q_PROPERTY(double area READ area NOTIFY areaChanged)

public:
    CompartmentEngine();

    double voltage() const;

    double capacitance() const;

    double length() const;

    double radiusA() const;

    double radiusB() const;

    double area() const;

signals:

    void voltageChanged(double voltage);

    void capacitanceChanged(double capacitance);

    void lengthChanged(double length);

    void radiusAChanged(double radiusA);

    void radiusBChanged(double radiusB);

    void areaChanged(double area);

public slots:
    void setVoltage(double voltage);
    void setCapacitance(double capacitance);

    // NeuronifyObject interface
    void setLength(double length);

    void setRadiusA(double radiusA);

    void setRadiusB(double radiusB);

protected:
    virtual void resetDynamicsEvent() override;
    virtual void resetPropertiesEvent() override;

    // NodeEngine interface
protected:
    virtual void stepEvent(double dt, bool parentEnabled) override;
    virtual void receiveCurrentEvent(double currentOutput, NodeEngine *sender) override;

private:
    void updateArea();

    double m_voltage = 0.0;
    double m_capacitance = 0.0;
    double m_receivedCurrents = 0.0;
    double m_length = 0.0;
    double m_radiusA = 0.0;
    double m_radiusB = 0.0;
    double m_area;
};

#endif // COMPARTMENTENGINE_H
