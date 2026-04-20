#include "defines\defines.hpp"
#include "defines\classDefines.hpp"

#define RENDER_TARGET_STR "cfmrendertarget"
#define ACTIONS_PRIORITY 956

#define FULLSCREEN_HINT_NL(nl) (format["TO EXIT FULLSCREEN MOVE BY MOUSE OR KEYBOARD! %1 АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ ПОВОРУХНІТСЯ (МИШКОЮ АБО КЛАВІШАМИ)!", nl])
#define FULLSCREEN_HINT FULLSCREEN_HINT_NL(endl)
#define FULLSCREEN_TEMPCAM_HINT_NL(nl) (format["TO EXIT FULLSCREEN PRESS 'CTRL + E' OR YOUR BIND. FULLSCREEN WILL AUTOMATICLY EXIT AFTER %2 SECONDS. %1 АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ НАТИСНІТЬ 'CTRL + E' АБО СВІЙ БІНД. ВИ ВИЙДЕТЕ З АВТОМАТИЧНО ПОВНОЕКРАННОГО РЕЖИМУ ЧЕРЕЗ %2 СЕКУНД.", nl, AUTOEXIT_FULLSCREEN_TIMER])
#define FULLSCREEN_TEMPCAM_HINT FULLSCREEN_TEMPCAM_HINT_NL(endl)
#define AUTOEXIT_FULLSCREEN_TIMER 120
#define CHECK_OP_COND_FREQ 1
#define DUMMY_CLASSNAME "Land_HelipadEmpty_F"
#define DO_INTERPOLATE_STATIC_CAMS false

// #define SET_MON_OP_REMOTE_EXEC