#ifndef BLUETOOTH_HANDLER
#define BLUETOOTH_HANDLER

class BluetoothHandler
{
public:
    virtual String getCommand()
    {
        return "";
    }

    virtual void handle(String args[], int argsLength){};
};

#endif