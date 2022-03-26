#include "../../services/sensors/Button.cpp"

namespace MiddleButton
{
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
        Serial.println("Mid: Long press");
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