#ifndef PROXIMITY_VIBRATOR_HANDLER
#define PROXIMITY_VIBRATOR_HANDLER

#include "../services/sensors/HC-SR04.cpp"

namespace ProximityVibrator
{
    const int _VibratorPort = 5;

    const int MIN_VIBRATION_VAL = 10;
    const int MAX_VIBRATION_VAL = 255;

    const int SENSOR_THRESHOLD = 100;

    const int VIBRATION_TIMOUT = 200;

    double _val = 0;

    void onUpdate(double distance)
    {
        _val = max(MIN_VIBRATION_VAL + (SENSOR_THRESHOLD - distance) * (MAX_VIBRATION_VAL - MIN_VIBRATION_VAL) / (SENSOR_THRESHOLD - 2), 0);
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
        analogWrite(_VibratorPort, _val);
    }
}

#endif