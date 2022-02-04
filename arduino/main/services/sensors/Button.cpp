#include <Arduino.h>

class Button
{
public:
    int port;

    // All times are in ms
    unsigned long singlePressPolling = 1000;
    // unsigned long doublePressTimeout = 500;
    // unsigned long longPressTimeout = 1000;

private:
    bool _prevState = false;
    bool _currentState = false;

    unsigned long _lastPressedAt = 0;

    // Handlers
    void (*_onPress)();

public:
    Button(
        int port,
        void (*onPress)()
        //
    )
    {
        port = port;
        _onPress = onPress;
        pinMode(port, INPUT);
    }

    // TODO: Add onDoublePress, onLongPress
    void listen()
    {
        _currentState = (bool)digitalRead(port);

        if (_currentState == _prevState)
            return;

        if (millis() >= (_lastPressedAt + singlePressPolling) && _currentState)
        {
            _onPress();
            _lastPressedAt = millis();
        }

        _prevState = _currentState;
    }
};