
#include "defines.hpp"

#ifndef ADDON
call FUNC(XEH_preStart);
#else
call compileScript [FUNC_PATH(XEH_prep.sqf)];
#endif

if (is3DEN) exitWith {
	call CFM_fnc_initSettings;
};

call CFM_fnc_initCBAEvents;
call CFM_fnc_init;