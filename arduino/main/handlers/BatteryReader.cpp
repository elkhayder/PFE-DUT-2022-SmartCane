#ifndef BATTERY_READER_HANDLER
#define BATTERY_READER_HANDLER

#include "../services/Bluetooth.cpp"

namespace BatteryReader
{
    const int batteryInputPin = A0;

    const int ledOutputPin = A2;

    int _lastValue = 100;

    bool _batteryPercentageSentOnConnect = false;

    void onValueChange(int value)
    {
        digitalWrite(ledOutputPin, value <= 20);

        if (value <= 20)
        {
            String batteryValue = String(value) + "%";
            Bluetooth::speak("Battery is low, " + batteryValue);
        }

        String args[1] = {String(value)};

        Bluetooth::send("BATTERY_PERCENTAGE", args, 1);
    }

    void setup()
    {
        pinMode(batteryInputPin, INPUT);
        pinMode(ledOutputPin, OUTPUT);

        onValueChange(_lastValue);
    }

    void loop()
    {
        int _read = analogRead(batteryInputPin);

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