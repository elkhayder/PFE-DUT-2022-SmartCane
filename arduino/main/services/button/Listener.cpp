#include <Arduino.h>

class ButtonListener
{
public:
    int port;
    unsigned long singlePressPolling = 1000; // in ms

private:
    unsigned long _lastPressedAt = 0;
    bool _prevState = false;
    bool _currentState = false;

public:
    ButtonListener(int p)
    {
        port = p;
        init();
    }

    void init()
    {
        pinMode(port, INPUT);
        Serial.println("Listening to button in port " + port);
    }

    void loop()
    {
        _currentState = (bool)digitalRead(port);

        if (_prevState == _currentState)
            return; // Exit if state haven't changed yet

        if (millis() < (_lastPressedAt + singlePressPolling))
            return; //Exit if not enough time have passed yet since last click

        onPress();
        _prevState = _currentState;
        _lastPressedAt = millis();
    }

    void onPress()
    {
        String stat = _currentState ? "Clicked" : "Not clicked";
        Serial.println(stat);
    }

    void onLongPress()
    {
    }
};