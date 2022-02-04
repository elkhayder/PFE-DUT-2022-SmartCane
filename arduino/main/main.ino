#include <Arduino.h>

#include "./services/bluetooth/Reciever.cpp"
#include "./services/sensors/Button.cpp"
#include "./services/sensors/HC-SR04.cpp"

void onPress()
{
  Serial.println("OnPress");
}

void sensorUpdate(int distance)
{
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println("cm");
}

Button leftButton(4, onPress);
HC_SR04 proximitySensor(7, 6, sensorUpdate);

void setup()
{
  Serial.begin(9600);
  leftButton.singlePressPolling = 500;
  proximitySensor.threshold = 50;
}

void loop()
{
  listenForBluetoothPayload();
  leftButton.listen();
  proximitySensor.listen();
}
