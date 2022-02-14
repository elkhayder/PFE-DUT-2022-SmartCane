#include "../services/Bluetooth.cpp"

namespace BatteryReader
{
    const int pin = A0;

    int _lastValue = 100;

    void onValueChange(int value)
    {
        String args[1] = {String(value)};

        Bluetooth::send("BATTERY_PERCENTAGE", args);
    }

    void setup()
    {
        pinMode(pin, INPUT);
        onValueChange(_lastValue);
    }

    void loop()
    {
        int _read = analogRead(pin);

        int _value = min(_read * 0.48828125, 100); // 5 * 100 / 1024 = 0.48828125

        if (_value != _lastValue)
        {
            onValueChange(_value);
            _lastValue = _value;
        }
    }

}