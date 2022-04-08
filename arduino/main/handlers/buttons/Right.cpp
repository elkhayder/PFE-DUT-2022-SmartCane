#include "../../services/sensors/Button.cpp"

#include "../../services/Bluetooth.cpp"

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
        String args[] = {"EXPLORE"};

        Bluetooth::send("NAVIGATABLES", args, 1);
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