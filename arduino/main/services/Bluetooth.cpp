#ifndef BLUETOOTH_SERVICE
#define BLUETOOTH_SERVICE

#include <SoftwareSerial.h>

namespace Bluetooth
{
    SoftwareSerial BTSerial(4, 3); // TXD | RXD
    const int statePin = 2;
    String _payloadBuffer;

    bool isConnected = false;

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

    void onConnect()
    {
    }

    //

    void setup()
    {
        BTSerial.begin(9600);
        pinMode(statePin, INPUT);
    }

    void loop()
    {
        bool isConnectNow = digitalRead(statePin);

        if (isConnectNow && !isConnected)
            onConnect();

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

        isConnected = isConnected;
    }

}

#endif