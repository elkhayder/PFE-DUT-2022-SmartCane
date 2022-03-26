#ifndef BUTTONS_ALL

#define BUTTONS_ALL

#include "./Bot.cpp"
#include "./Mid.cpp"
#include "./Top.cpp"
#include "./Left.cpp"
#include "./Right.cpp"

namespace ButtonsAll
{
    void setup()
    {
        LeftButton::setup();
        RightButton::setup();
        MiddleButton::setup();
        TopButton::setup();
        BottomButton::setup();
    }

    void loop()
    {
        LeftButton::loop();
        RightButton::loop();
        MiddleButton::loop();
        TopButton::loop();
        BottomButton::loop();
    }
}

#endif