#ifndef RINGTONES_CPP

#define RINGTONES_CPP

#include "./pitches.h"

class Ringtone
{
public:
    static const int MAX_LENGTH = 100;
    // int notes[MAX_LENGTH] PROGMEM = {}; //[MAX_LENGTH] PROGMEM = {};
    const int *notes;
    int length;
    int duration;
    int sleep;

    Ringtone(const int *_notes, int _length, int _duration, int _delay)
    {
        // for (int i = 0; i < _length; i++)
        // {
        //     notes[i] = _notes[i];
        // }

        notes = _notes;

        length = _length;
        duration = _duration;
        sleep = _delay;
    }

    void play()
    {
        for (int i = 0; i < length; i++)
        {
            tone(11, notes[i], duration);
            delay(sleep);
        }
    }
};

namespace Ringtones
{
    const int startupMelody[] = {NOTE_E6, NOTE_C7, NOTE_A6, NOTE_B6};
    Ringtone startup(startupMelody, 4, 200, 150);

    const int ringtoneMelody[] = {NOTE_A7, NOTE_D7};
    Ringtone ringtone(ringtoneMelody, 2, 250, 150);

    const int buttonClickMelody[] = {0, NOTE_E6, 0};
    Ringtone buttonClick(buttonClickMelody, 3, 150, 100);

    const int buttonDoubleClickMelody[] = {0, NOTE_F5, 0};
    Ringtone buttonDoubleClick(buttonDoubleClickMelody, 3, 150, 100);

    const int buttonLongClickMelody[] = {0, NOTE_CS6, 0};
    Ringtone buttonLongClick(buttonLongClickMelody, 3, 150, 100);
}

#endif