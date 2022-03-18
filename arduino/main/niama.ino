#include <Servo.h>
#include <IRremote.h>

/**
 * Servo: 6
 * Remote: 7
 */

Servo gate;
IRrecv remote(7);

int placesSensors[] = {3, 4, 5};
int placesCount = 3;

decode_results results;

void setup()
{
    gate.attach(6);
    remote.enableIRIn();
}

void loop()
{
    bool placeIsAvailable[3];
    int availablePlacesCount = 0;

    for (int i = 0; i < placesCount; i++)
    {
        if (readDistance(placesSensors[i]) > 100)
        {
            availablePlacesCount++;
            placeIsAvailable[i] = true;
        }
        else
        {
            placeIsAvailable[i] = false;
        }
    }

    if (remote.decode(&results))
    {
        // Serial.println(results.value, HEX);

        switch (results.value)
        {
        case 0xFD50AF: // open
            openGate();
            break;

        case 0xFD10EF: // close
            closeGate();
            break;
        }

        remote.resume();
    }
}

long readDistance(int pin)
{
    // Trigger sensor
    pinMode(pin, OUTPUT);
    digitalWrite(pin, LOW);
    delayMicroseconds(2);
    digitalWrite(pin, HIGH);
    delayMicroseconds(10);
    digitalWrite(pin, LOW);

    // Calculate duration
    pinMode(pin, INPUT);
    long long duration = pulseIn(pin, HIGH);
    long distance = 0.01723 * duration;

    return distance;
}

void openGate()
{
    gate.write(90);
}

void closeGate()
{
    gate.write(0);
}