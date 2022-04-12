#include <Arduino.h>

#define echo 8
#define trig 7

void setup()
{
    Serial.begin(9600);
}

void loop()
{
    digitalWrite(trig, HIGH);
    delayMicroseconds(10);
    digitalWrite(trig, LOW);

    unsigned long duration = pulseIn(echo, HIGH);

    double distance = 340 * 0.0001 * duration / 2;

    Serial.print("Duration: ");
    Serial.print(duration);
    Serial.println("μs");

    Serial.print("Distance: ");
    Serial.print(distance);
    Serial.println("cm");

    delay(1000);
}