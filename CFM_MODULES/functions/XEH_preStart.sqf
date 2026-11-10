#include "defines.hpp"

#ifndef ADDON
call FUNC(XEH_prep);
#else
call compileScript [FUNC_PATH(XEH_prep.sqf)];
#endif

if (isNil "CFM_fnc_parseModuleAttributesForZen") then {
    CFM_fnc_parseModuleAttributesForZen = compileScript [FUNC_PATH(fn_parseModuleAttributesForZen.sqf)];
};
call CFM_fnc_parseModuleAttributesForZen;
