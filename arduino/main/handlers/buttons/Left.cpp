#include "../../services/sensors/Button.cpp"

#include "../../services/Bluetooth.cpp"

namespace LeftButton
{
    void onPress()
    {
        String args[] = {"PREVIOUS"};

        Bluetooth::send("NAVIGATABLES", args, 1);
    }

    void onDoublePress()
    {
        Serial.println("Left: Double press");
    }

    void onLongPress()
    {
        Serial.println("Left: Long press");
    }

    Button button(6, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}