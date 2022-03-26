#include "../../services/sensors/Button.cpp"

namespace BottomButton
{
    void onPress()
    {
        Serial.println("Bot: On click");
    }

    void onDoublePress()
    {
        Serial.println("Bot: Double press");
    }

    void onLongPress()
    {
        Serial.println("Bot: Long press");
    }

    Button button(9, onPress, onDoublePress, onLongPress);

    void setup()
    {
    }

    void loop()
    {
        button.listen();
    }
}