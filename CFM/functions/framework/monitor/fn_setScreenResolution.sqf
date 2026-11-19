/*
    Function: CFM_fnc_setScreenResolution
    Author: Vazar & Gemini
    Description:
        Sets screen resolution parameters on a monitor instance (or all instances on a monitor object)
        and restarts active UI/R2T feeds if needed.
        Wraps Monitor::setScreenResolution (PUBLIC GE GA - Config set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _resolution [String | Array] - Resolution string (e.g. "16:9", "16:9 {0.8, 0.8}") or parsed resolution array.
    Returns:
        [Array | Boolean] - Applied screen resolution array, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_resolution", ""]];

if (IS_VALID_MON(_monArg)) exitWith {
	["setScreenResolution", [_resolution]] CALL_MON_INST(_monArg select 0, _monArg select 1)
};
if !(_monArg isEqualType objNull && {IS_OBJ(_monArg)}) exitWith {false};

private _keys = keys (_monArg getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
if (_keys isEqualTo []) exitWith {false};
private _res = DEFAULT_SCREEN_RESOLUTION;
{
	_res = ["setScreenResolution", [_resolution]] CALL_MON_INST(_monArg, _x);
} forEach _keys;
_res
