#include "../../services/sensors/Button.cpp"

namespace TopButton
{
    void onPress()
    {
        Serial.println("Top: On click");
    }

    void onDoublePress()
    {
        Serial.println("Top: Double press");
    }

    void onLongPress()
    {
        Bluetooth::send("SEND_LOCATION_SMS", {}, 0);
    }

    Button button(10, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}