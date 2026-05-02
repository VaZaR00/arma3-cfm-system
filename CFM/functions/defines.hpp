#include "defines\defines.hpp"
// #include "..\includes\main.hpp"
#include "..\..\..\main_mission.hpp"
#include "Classes\defines\classDefinesVer1.hpp"
#include "Classes\defines\objClassDefines.hpp"

#define RENDER_TARGET_STR "cfmrendertarget"
#define ACTIONS_PRIORITY 956

#define FULLSCREEN_HINT_NL(nl) (format["TO EXIT FULLSCREEN MOVE BY MOUSE OR KEYBOARD! %1 АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ ПОВОРУХНІТСЯ (МИШКОЮ АБО КЛАВІШАМИ)!", nl])
#define FULLSCREEN_HINT FULLSCREEN_HINT_NL(endl)
#define FULLSCREEN_TEMPCAM_HINT_NL(nl) (format["%2 %1 %3", nl, FULLSCREEN_TEMPCAM_HINT_ENG, FULLSCREEN_TEMPCAM_HINT_UKR])
#define FULLSCREEN_TEMPCAM_HINT_ENG "TO EXIT FULLSCREEN PRESS 'CTRL + E' OR YOUR BIND."
#define FULLSCREEN_TEMPCAM_HINT_UKR "АБИ ВИЙТИ З ПОВНОЕКРАННОГО РЕЖИМУ НАТИСНІТЬ 'CTRL + E' АБО СВІЙ БІНД."
#define FULLSCREEN_TEMPCAM_HINT FULLSCREEN_TEMPCAM_HINT_NL(endl)
#define CHECK_OP_COND_FREQ 1
#define DUMMY_CLASSNAME "Land_HelipadEmpty_F"
#define DO_INTERPOLATE_STATIC_CAMS true
#define DO_INTERPOLATE_TOLERANCE 0.0001

#define SET_MON_OP_REMOTE_EXEC