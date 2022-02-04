#include <Arduino.h>

class Button
{
public:
    // All times are in ms
    unsigned long singlePressPolling = 1000;
    unsigned long doublePressTimeout = 250;
    // unsigned long longPressTimeout = 1000;

private:
    int _port;

    bool _prevState = false;
    bool _currentState = false;

    bool _singlePressInQueue = false;

    unsigned long _lastPressedAt = 0;

    // Handlers
    void (*_onPress)();
    void (*_onDoublePress)();

public:
    Button(
        int port,
        void (*onPress)(),
        void (*onDoublePress)()
        //
    )
    {
        _port = port;
        _onPress = onPress;
        _onDoublePress = onDoublePress;
        pinMode(port, INPUT);
    }

    // TODO: Add onLongPress
    void listen()
    {
        _currentState = (bool)digitalRead(_port);

        if (_singlePressInQueue)
        {
            if (millis() <= _lastPressedAt + doublePressTimeout && _currentState && !_prevState)
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
            _lastPressedAt = millis();
        }

        _prevState = _currentState;
    }
};