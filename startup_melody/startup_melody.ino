//Libraries
#include "pitches.h" //https://www.arduino.cc/en/Tutorial/toneMelody

//Parameters
const int buzPin  = 11;

void setup() {
  //Init Serial USB
 
  Serial.begin(9600);
  Serial.println(F("Initialize System"));
}

void loop() {
   

 
  playPassed();
    delay(1000);
  
  
}

void playPassed() { /* function playPassed */
  ////Play 'ON' Sound
  int melodyOn[] = {NOTE_E6,NOTE_C7,NOTE_A6,NOTE_B6};
  int durationOn = 200;
  for (int thisNote = 0; thisNote <4; thisNote++) {
    tone(buzPin, melodyOn[thisNote], durationOn);
    delay(150);
  }
}

void playFailed() { /* function playFailed */
  ////Play 'OFF' Sound
  int melodyOff[] = {NOTE_A6,NOTE_D7,NOTE_E7};
  int durationOff = 250;
  for (int thisNote = 0; thisNote < 3; thisNote++) {
    tone(buzPin, melodyOff[thisNote], durationOff);
    delay(100);
   }}
