/*
    Function: CFM_fnc_setScreenResolution
    Author: Vazar
    Description:
        Sets screen resolution on a monitor object.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_resolution", ""], ["_global", false]];

if (IS_VALID_MON(_monArg)) exitWith {
	["setScreenResolution", [_resolution, _global]] CALL_MON_INST(_monArg select 0, _monArg select 1)
};
if !(_monArg isEqualType objNull && {IS_OBJ(_monArg)}) exitWith {false};

private _keys = keys (_monArg getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
if (_keys isEqualTo []) exitWith {false};
private _res = DEFAULT_SCREEN_RESOLUTION;
{
	_res = ["setScreenResolution", [_resolution, _global]] CALL_MON_INST(_monArg, _x);
} forEach _keys;
_res
