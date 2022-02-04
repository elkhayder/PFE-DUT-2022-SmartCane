#include <Arduino.h>
#include "Serial.cpp"

void sendBluetoothPayload(String command, String args[])
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
    BTSerial.print(payload); // Send payload
}