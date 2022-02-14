#include "../services/sensors/Button.cpp"

#include "../services/Bluetooth.cpp"

namespace LeftButton
{
    void onPress()
    {
        // Serial.println("Sending SMS");

        Bluetooth::send("SEND_LOCATION_SMS", {});
    }

    void onDoublePress()
    {
        Serial.println("Double press");
    }

    void onLongPress()
    {
        Serial.println("Long press");
    }

    Button button(7, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}