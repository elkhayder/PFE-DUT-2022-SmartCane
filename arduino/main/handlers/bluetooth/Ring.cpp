#ifndef RING_HANDLER
#define RING_HANDLER

#include "./Handler.cpp"
#include "../../includes/ringtones.cpp"

namespace RingHandler
{
    void handle(String args[], int length)
    {
        for (int i = 0; i < 10; i++)
            Ringtones::ringtone.play();
    }

    BluetoothHandler handler("RING", handle);
}

#endif