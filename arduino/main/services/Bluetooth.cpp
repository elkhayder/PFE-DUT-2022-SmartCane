#ifndef BLUETOOTH_SERVICE
#define BLUETOOTH_SERVICE

#include <SoftwareSerial.h>

namespace Bluetooth
{
    SoftwareSerial BTSerial(4, 5); // TXD | RXD
    String _payloadBuffer;

    void setup()
    {
        BTSerial.begin(9600);
    }

    void loop()
    {
        if (BTSerial.available())
        {
            int thisChar = BTSerial.read();
            if (thisChar == 0xA)
            {
                parsePayload(_payloadBuffer); // Parse payload
                _payloadBuffer = "";          // Reset payload buffer
            }
            else
            {
                _payloadBuffer += ((char)thisChar); // Add current char to bufferPayload
            }
        }
    }

    void send(String command, String args[])
    {
        String payload = command + ":";
        int argsLength = sizeof(args) / sizeof(String);
        for (int i = 0; i < argsLength; i++)
        {
            payload += args[i];
            if (i != (argsLength - 1)) // Add pipe char (|) between args
                payload += "|";
        }
        payload += ((char)0x0A); // Add \n char

        Serial.println(payload);

        BTSerial.print(payload); // Send payload
    }

    void parsePayload(String payload)
    {
        Serial.print(payload);
    }
}

#endif