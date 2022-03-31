#include "../../services/sensors/Button.cpp"

#include "../../services/Bluetooth.cpp"

namespace MiddleButton
{
    bool ledIsHigh = false;

    uint8_t ledPin = A1;

    void onPress()
    {
        Serial.println("Mid: On click");
    }

    void onDoublePress()
    {
        Serial.println("Mid: Double press");
    }

    void onLongPress()
    {
        // Serial.println("Mid: Long press");
        ledIsHigh = !ledIsHigh;
        digitalWrite(ledPin, ledIsHigh);

        String state = ledIsHigh ? "on" : "off";

        Bluetooth::speak("Lights are " + state);
    }

    Button button(13, onPress, onDoublePress, onLongPress);

    void setup()
    {
        pinMode(ledPin, OUTPUT);
    }

    void loop()
    {
        button.listen();
    }
}