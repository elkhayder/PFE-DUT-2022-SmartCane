#include <Arduino.h>

// TODO: Remove those
#define DEBUG_OUT Serial
#include <Arduino_Helpers.h>
#include <AH/Debug/Debug.hpp>

class HC_SR04
{
public:
    double threshold = 0;      // in cm
    unsigned long polling = 0; // in ms

private:
    int _echoPin;
    int _trigPin;
    void (*_onUpdate)(double);

    bool _isTriggering = false;
    unsigned long _triggeringStartedAt = 0;
    bool _isEchoing = false;
    unsigned long _echoingStartedAt = 0;

public:
    // echo, trig
    HC_SR04(
        int echo,
        int trig,
        void (*onUpdate)(double)
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
        if (_isEchoing)
        {

            bool _echoState = (bool)digitalRead(_echoPin);

            // Serial.println(_echoState);

            if (_echoState && !_echoingStartedAt)
            {
                _echoingStartedAt = micros();
            }

            if (!_echoState && _echoingStartedAt)
            {
                unsigned long _duration = micros() - _echoingStartedAt;
                double _distance = _duration * 0.034 / 2;
                _isEchoing = false;
                _echoingStartedAt = 0;

                _onUpdate(_distance);
            }
        }
        else
        {
            if (!_isTriggering)
            {
                digitalWrite(_trigPin, HIGH);
                _triggeringStartedAt = micros();
                _isTriggering = true;
            }
            else if (_isTriggering && micros() >= _triggeringStartedAt + 10)
            {
                digitalWrite(_trigPin, LOW);
                _triggeringStartedAt = 0;
                _isTriggering = false;
                _isEchoing = true;
            }
        }
    }
};