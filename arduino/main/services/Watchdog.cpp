class Watchdog
{
    unsigned long long fedAt = 0;

public:
    unsigned long long barkAfter = 1000;

    bool bark = false;

    Watchdog()
    {
        fedAt = millis();
    }

    void watch()
    {
        bark = millis() > (fedAt + barkAfter);
    }

    void feed()
    {
        fedAt = millis();
    }
};
