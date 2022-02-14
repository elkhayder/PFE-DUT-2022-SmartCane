#include <Arduino.h>

class Button
{
public:
    // All times are in ms
    unsigned long singlePressPolling = 1000;
    unsigned long doublePressTimeout = 250;
    unsigned long longPressTriggerTimeout = 1000;
    unsigned long minPressPolling = 10;
    // unsigned long longPressTimeout = 1000;

private:
    int _port;

    bool _prevState = false;
    bool _currentState = false;

    bool _singlePressInQueue = false;
    bool _longPressInProgress = false;

    unsigned long _lastPressedAt = 0;

    // Handlers
    void (*_onPress)();
    void (*_onDoublePress)();
    void (*_onLongPress)();

    static void _defaultHandler() {}

public:
    Button(
        int port,
        void (*onPress)(),
        void (*onDoublePress)() = _defaultHandler,
        void (*onLongPress)() = _defaultHandler
        //
    )
    {
        _port = port;
        _onPress = onPress;
        _onDoublePress = onDoublePress;
        _onLongPress = onLongPress;

        pinMode(port, INPUT);
    }

    void listen()
    {
        _currentState = (bool)digitalRead(_port);

        if (millis() < _lastPressedAt + minPressPolling)
            return;

        if (_singlePressInQueue)
        {
            if (_currentState && _prevState)
            {
                if (millis() >= _lastPressedAt + longPressTriggerTimeout)
                {
                    _onLongPress();
                    _singlePressInQueue = false;
                    _longPressInProgress = false;
                    _lastPressedAt = millis();
                }
            }
            else if (millis() <= _lastPressedAt + doublePressTimeout && _currentState && !_prevState)
            {
                _onDoublePress();
                _singlePressInQueue = false;
                _lastPressedAt = millis();
            }
            else if (millis() > _lastPressedAt + doublePressTimeout)
            {
                _onPress();
                _singlePressInQueue = false;
                _lastPressedAt = millis();
            }
        }
        else if (millis() >= _lastPressedAt + singlePressPolling && _currentState && !_prevState)
        {
            _singlePressInQueue = true;
            _longPressInProgress = false;
            _lastPressedAt = millis();
        }

        _prevState = _currentState;
    }
};