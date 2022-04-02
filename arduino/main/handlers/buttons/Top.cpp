#include "../../services/sensors/Button.cpp"

#include "../../services/Bluetooth.cpp"

namespace TopButton
{
    void onPress()
    {
        String args[] = {"BACK"};

        Bluetooth::send("NAVIGATABLES", args, 1);
    }

    void onDoublePress()
    {
    }

    void onLongPress()
    {
        String args[] = {"RESET"};

        Bluetooth::send("NAVIGATABLES", args, 1);
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