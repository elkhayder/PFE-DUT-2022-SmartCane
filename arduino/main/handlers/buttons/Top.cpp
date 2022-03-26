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
        Serial.println("Top: Long press");
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