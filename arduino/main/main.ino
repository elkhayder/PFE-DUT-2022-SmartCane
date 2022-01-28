#include <SoftwareSerial.h> 

SoftwareSerial BTSerial(2, 3); // TXD | RXD 

void setup() {
  BTSerial.begin(9600);
  Serial.begin(9600);
}

void loop() {
  if(BTSerial.available()) {
    Serial.write((char) BTSerial.read());
  }

  if(Serial.available()) {
    BTSerial.write((char) Serial.read());
  }
}
