#ifndef RING_HANDLER
#define RING_HANDLER

#include "./Handler.cpp"
#include "../../includes/ringtones.cpp"

class RingHandler : public BluetoothHandler
{
public:
    String getCommand() override
    {
        return "RING";
    }

    void handle(String args[], int length) override
    {
        Serial.print("ringing");
        // startPlayback(Ringtone::ringtone, sizeof(Ringtone::ringtone));
    }
};

#endif