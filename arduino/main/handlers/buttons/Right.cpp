#include "../../services/sensors/Button.cpp"

namespace RightButton
{
    void onPress()
    {
        Serial.println("Right: On click");
    }

    void onDoublePress()
    {
        Serial.println("Right: Double press");
    }

    void onLongPress()
    {
        Serial.println("Right: Long press");
    }

    Button button(13, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}