#include <Arduino.h>

class HC_SR04
{
public:
    int threshold = NULL;

private:
    int _echoPin;
    int _trigPin;

    unsigned long _trigAt = NULL;
    unsigned long _echoHighAt = NULL;

    bool _waitingForEcho = false;
    void (*_onUpdate)(int);

public:
    HC_SR04(
        int echo,
        int trig,
        void (*onUpdate)(int)
        //
    )
    {
        _echoPin = echo;
        _trigPin = trig;
        _onUpdate = onUpdate;

        pinMode(_trigPin, OUTPUT);
        pinMode(_echoPin, INPUT);

        digitalWrite(_trigPin, LOW);
    }

    void listen()
    {
        bool _echoIsHigh = (bool)digitalRead(_echoPin);

        if (!_waitingForEcho)
        {
            if (_trigAt == NULL)
            {
                digitalWrite(_trigPin, HIGH);
                _trigAt = micros();
                return;
            }
            else
            {
                if (micros() >= _trigAt + 20)
                {
                    digitalWrite(_trigPin, LOW);
                    _waitingForEcho = true;
                    _trigAt = NULL;
                }
            }
        }
        else
        {
            if (_echoHighAt == NULL)
            {
                if (_echoIsHigh)
                    _echoHighAt = micros();
            }
            else
            {
                if (!_echoIsHigh)
                {
                    unsigned long _time = micros() - _echoHighAt;
                    int _distance = 0.034 * _time / 2; // in cm
                    _echoHighAt = NULL;
                    _waitingForEcho = false;
                    if (threshold != NULL && _distance <= threshold)
                        _onUpdate(_distance);
                }
            }
        }
    }
};