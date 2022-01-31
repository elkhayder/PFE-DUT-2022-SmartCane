#include <Arduino.h>

#include "./services/bluetooth/Reciever.cpp"
#include "./services/button/Listener.cpp"

ButtonListener firstButton(4);

void setup()
{
  Serial.begin(9600);
}

void loop()
{
  listenForBluetoothPayload();
  firstButton.loop();
}
