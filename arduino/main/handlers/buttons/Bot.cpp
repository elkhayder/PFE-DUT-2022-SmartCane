#include "../../services/sensors/Button.cpp"

#include "../../services/Bluetooth.cpp"
namespace BottomButton
{
    void onPress()
    {
        String args[] = {"PRESS"};

        Bluetooth::send("NAVIGATABLES", args, 1);
    }

    void onDoublePress()
    {
    }

    void onLongPress()
    {
        Bluetooth::send("RING", {}, 0);
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