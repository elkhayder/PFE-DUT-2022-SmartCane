#ifndef BLUETOOTH_HANDLER
#define BLUETOOTH_HANDLER

class BluetoothHandler
{
public:
    //     virtual String getCommand();
    String command;
    void (*handle)(String[], int);

    BluetoothHandler(
        String _command,
        void (*_handle)(String[], int))
    {
        command = _command;
        handle = _handle;
    }

    //     virtual void handle(String args[], int argsLength);
};

#endif