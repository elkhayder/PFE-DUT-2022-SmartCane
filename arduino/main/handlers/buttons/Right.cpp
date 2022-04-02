#include "../../services/sensors/Button.cpp"

namespace RightButton
{
    void onPress()
    {
        String args[] = {"NEXT"};

        Bluetooth::send("NAVIGATABLES", args, 1);
    }

    void onDoublePress()
    {
        Serial.println("Right: Double press");
    }

    void onLongPress()
    {
        Bluetooth::send("SEND_LOCATION_SMS", {}, 0);
    }

    Button button(12, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}