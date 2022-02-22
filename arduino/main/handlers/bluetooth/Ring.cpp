#ifndef RING_HANDLER
#define RING_HANDLER

#include "./Handler.cpp"

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
    }
};

#endif