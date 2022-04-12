#ifndef PROXIMITY_VIBRATOR_HANDLER
#define PROXIMITY_VIBRATOR_HANDLER

#include "../services/sensors/HC-SR04.cpp"

namespace ProximityVibrator
{
    const int _VibratorPort = 5;

    const int MIN_VIBRATION_VAL = 50;
    const int MAX_VIBRATION_VAL = 254;

    const int SENSOR_THRESHOLD = 100;

    const int VIBRATION_TIMOUT = 200;

    void onUpdate(double distance)
    {
        int _val = max(MIN_VIBRATION_VAL + (SENSOR_THRESHOLD - distance) * (MAX_VIBRATION_VAL - MIN_VIBRATION_VAL) / (SENSOR_THRESHOLD - 2), 0);
        if (_val < MIN_VIBRATION_VAL)
            _val = 0;
        analogWrite(_VibratorPort, _val);
        Serial.println(distance);
    }

    HC_SR04 sensor(8, 7, onUpdate); // Echo, Trig, onUpdate

    void setup()
    {
        pinMode(_VibratorPort, OUTPUT);
        sensor.threshold = SENSOR_THRESHOLD;
    }

    void loop()
    {
        sensor.listen();
    }
}

#endif