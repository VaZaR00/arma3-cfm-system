/*
    Function: CFM_fnc_getMonitorScreenResolution
    Author: Vazar
    Description:
        Returns the active [width, height] screen resolution for the given monitor object.
*/

#include "defines.hpp"

params [["_monitor", objNull]];

if !(IS_OBJ(_monitor)) exitWith {+DEFAULT_SCREEN_RESOLUTION};

private _res = _monitor getVariable "CFM_screenResolution";
if (!isNil "_res") then {
	if (_res isEqualType "") then {
		_res = [_res] call CFM_fnc_parseScreenResolution;
	};
	if ((_res isEqualType []) && {count _res >= 2}) exitWith {
		_monitor setVariable ["CFM_screenResolution", _res];
		+_res
	};
};

_res = [_monitor] call CFM_fnc_getDefaultScreenResolution;
_monitor setVariable ["CFM_screenResolution", _res];
+_res
