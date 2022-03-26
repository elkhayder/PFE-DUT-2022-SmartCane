#ifndef BLUETOOTH_SERVICE
#define BLUETOOTH_SERVICE

#include <SoftwareSerial.h>

#include "../handlers/bluetooth/Handler.cpp"
#include "../handlers/bluetooth/Ring.cpp"

// TODO: Remove those
#define DEBUG_OUT Serial
#include <Arduino_Helpers.h>
#include <AH/Debug/Debug.hpp>

namespace Bluetooth
{
    SoftwareSerial BTSerial(4, 3); // TXD | RXD
    const int statePin = 2;
    String _payloadBuffer;

    bool isConnected = false;

    const int _handlersCount = 1;
    const BluetoothHandler _handlers[] = {
        RingHandler(),
    };

    void send(String command, String args[], int length)
    {
        String payload = command + ":";

        for (int i = 0; i < length; i++)
        {
            payload += args[i];
            if (i != (length - 1)) // Add pipe char (|) between args
                payload += "|";
        }
        payload += ((char)0x0A); // Add \n char

        BTSerial.print(payload); // Send payload
    }

    void parsePayload(String payload)
    {
        int indexOfDoublePoints = payload.indexOf(":");

        String command = payload.substring(0, indexOfDoublePoints);

        String argsString = payload.substring(indexOfDoublePoints + 1);

        String args[] = {};

        int argsLength = 0;

        int indexOfPipe = -1;

        int currentPipeSearchIndex = 0;

        do
        {
            indexOfPipe = argsString.substring(currentPipeSearchIndex).indexOf("|");

            String arg = argsString.substring(currentPipeSearchIndex, indexOfPipe);

            currentPipeSearchIndex += arg.length() + 1;

            args[argsLength] = arg;

            argsLength++;

        } while (indexOfPipe != -1);

        DEBUGVAL(command);

        for (int i = 0; i < argsLength; i++)
        {
            DEBUGVAL(args[i]);
        }

        for (int i = 0; i < _handlersCount; i++)
        {
            BluetoothHandler handler = _handlers[i];
            if (handler.getCommand() == command)
            {
                handler.handle(args, argsLength);
                break;
            }
        }
    }

    void onConnect()
    {
        // BatteryReader::onValueChange(BatteryReader::_lastValue);
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
                Serial.println(_payloadBuffer);
                parsePayload(_payloadBuffer); // Parse payload
                _payloadBuffer = "";          // Reset payload buffer
            }
            else
            {
                _payloadBuffer += ((char)thisChar); // Add current char to bufferPayload
            }
        }

        isConnected = isConnectNow;
    }

}

#endif