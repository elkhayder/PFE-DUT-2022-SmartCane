#include <Arduino.h>

#include "./services/Bluetooth.cpp"

#include "./handlers/ProximityVibrator.cpp"
#include "./handlers/BatteryReader.cpp"
#include "./handlers/buttons/all.h"

#include "./includes/ringtones.cpp"

void setup()
{
    Serial.begin(9600);

    Bluetooth::setup();

    ProximityVibrator::setup();

    BatteryReader::setup();

    ButtonsAll::setup();

    // Startup melody
    for (int i = 0; i < Ringtone::startup_size; i++)
    {
        tone(11, Ringtone::startup_melody[i], Ringtone::startup_duration);
        delay(150);
    }

    delay(1000);
}

void loop()
{
    Bluetooth::loop();

    ProximityVibrator::loop();

    BatteryReader::loop();

    ButtonsAll::loop();
}
