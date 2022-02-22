#include <Arduino.h>

#include "./services/Bluetooth.cpp"

#include "./handlers/ProximityVibrator.cpp"
#include "./handlers/BatteryReader.cpp"
#include "./handlers/LeftButton.cpp"

void setup()
{
    Serial.begin(9600);

    Bluetooth::setup();
    //
    ProximityVibrator::setup();
    BatteryReader::setup();
    LeftButton::setup();
}

void loop()
{
    // Bluetooth::loop();
    //
    ProximityVibrator::loop();
    // BatteryReader::loop();
    LeftButton::loop();
}
