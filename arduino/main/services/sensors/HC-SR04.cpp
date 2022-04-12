#include <Arduino.h>

#include "../Watchdog.cpp"

// TODO: Remove those
#define DEBUG_OUT Serial
#include <Arduino_Helpers.h>
#include <AH/Debug/Debug.hpp>

class HC_SR04
{

public:
    double threshold = 0;      // in cm
    unsigned long polling = 0; // in ms

    Watchdog watchdog;

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

        watchdog.barkAfter = 500;
    }

    void listen()
    {
        digitalWrite(_trigPin, LOW);
        delayMicroseconds(2);
        digitalWrite(_trigPin, HIGH);
        delayMicroseconds(10);
        digitalWrite(_trigPin, LOW);
        int duration = pulseIn(_echoPin, HIGH);
        int distance = duration * 0.034 / 2;
        _onUpdate(distance);

        // watchdog.watch();

        // if (watchdog.bark)
        // {
        //     // reset();
        //     watchdog.feed();
        //     // return;
        // }

        // DEBUGVAL(_isTriggering, _triggeringStartedAt, _echoingStartedAt, _isEchoing, digitalRead(_echoPin));

        // if (_isEchoing)
        // {
        //     // bool _echoState = (bool)digitalRead(_echoPin);

        //     // Serial.println(_echoState);

        //     if (digitalRead(_echoPin) && !_echoingStartedAt)
        //     {
        //         _echoingStartedAt = micros();
        //     }

        //     if (!digitalRead(_echoPin) && _echoingStartedAt)
        //     {
        //         unsigned long _duration = micros() - _echoingStartedAt;
        //         double _distance = _duration * 0.034 / 2;

        //         _isEchoing = false;
        //         _echoingStartedAt = 0;

        //         watchdog.feed();

        //         _onUpdate(_distance);
        //     }
        // }
        // else
        // {
        //     // digitalWrite(_trigPin, HIGH);
        //     // delayMicroseconds(10);
        //     // digitalWrite(_trigPin, LOW);
        //     // _isEchoing = true;
        //     // delayMicroseconds(2);

        //     if (!_isTriggering)
        //     {
        //         if (micros() < _triggeringStartedAt + 60)
        //             return;

        //         digitalWrite(_trigPin, HIGH);
        //         _triggeringStartedAt = micros();
        //         _isTriggering = true;
        //     }
        //     else if (_isTriggering && micros() >= _triggeringStartedAt + 10)
        //     {
        //         digitalWrite(_trigPin, LOW);
        //         _triggeringStartedAt = 0;
        //         _isTriggering = false;
        //         _isEchoing = true;
        //         // _echoingStartedAt = micros();
        //     }
        // }
    }

    void reset()
    {
        Serial.println("reset");
        _isTriggering = false;
        _triggeringStartedAt = 0;
        _isEchoing = false;
        _echoingStartedAt = 0;
    }
};