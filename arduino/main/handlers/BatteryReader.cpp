#ifndef BATTERY_READER_HANDLER
#define BATTERY_READER_HANDLER

#include "../services/Bluetooth.cpp"

namespace BatteryReader
{
    const int pin = A0;

    int _lastValue = 100;

    bool _batteryPercentageSentOnConnect = false;

    void onValueChange(int value)
    {
        String args[1] = {String(value)};

        Bluetooth::send("BATTERY_PERCENTAGE", args, 1);
    }

    void setup()
    {
        pinMode(pin, INPUT);
        onValueChange(_lastValue);
    }

    void loop()
    {
        int _read = analogRead(pin);

        int _value = _read / 10.24; // 5 * 100 / 1024 = 0.48828125

        if (_value != _lastValue || (!_batteryPercentageSentOnConnect && Bluetooth::isConnected))
        {
            onValueChange(_value);
            _lastValue = _value;
            if (!_batteryPercentageSentOnConnect)
                _batteryPercentageSentOnConnect = true;
        }
    }

}

#endif