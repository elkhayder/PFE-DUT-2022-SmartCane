#ifndef RINGTONES_CPP

#define RINGTONES_CPP

#include "./pitches.h"

namespace Ringtone
{
    const unsigned int startup_melody[] PROGMEM = {NOTE_E6, NOTE_C7, NOTE_A6, NOTE_B6};
    const int startup_duration = 200;
    const int startup_size = 3;

    const unsigned int ringtone[] PROGMEM = {NOTE_A7, NOTE_D7};
    const int ringtone_duration = 250;
    const int ringtone_size = 2;
}

#endif