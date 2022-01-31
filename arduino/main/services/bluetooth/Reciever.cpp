#include <Arduino.h>
#include "Serial.cpp"

String _payloadBuffer;

void parseBluetoothPayload(String payload)
{
}

void listenForBluetoothPayload()
{
    if (BTSerial.available())
    {
        int thisChar = BTSerial.read();
        if (thisChar == 0xA)
        {
            parseBluetoothPayload(_payloadBuffer); // Parse payload
            _payloadBuffer = "";                   // Reset payload buffer
        }
        else
        {
            _payloadBuffer += ((char)thisChar); // Add current char to bufferPayload
        }
    }
}
