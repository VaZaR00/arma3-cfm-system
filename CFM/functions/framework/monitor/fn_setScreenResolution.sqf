/*
    Function: CFM_fnc_setScreenResolution
    Author: Vazar & Gemini
    Description:
        Sets screen resolution parameters on a monitor instance (or all instances on a monitor object)
        via Monitor::setScreenResolution and restarts active UI/R2T feeds on target machines.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _resolution [String | Array] - Resolution string (e.g. "16:9", "16:9 {0.8, 0.8}") or parsed resolution array.
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Array | Boolean | String] - Applied screen resolution array locally, JIP ID if global, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_resolution", ""], ["_target", true]];

if (IS_VALID_MON(_monArg)) exitWith {
	_monArg params ["_monitor", "_instId"];
	private _execTarget = if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {false} else {_target};
	["setScreenResolution", [_resolution], _execTarget, DEFAULT_SCREEN_RESOLUTION] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor)
};
if !(_monArg isEqualType objNull && {IS_OBJ(_monArg)}) exitWith {false};

private _keys = keys (_monArg getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
if (_keys isEqualTo []) exitWith {false};
private _res = DEFAULT_SCREEN_RESOLUTION;
{
	private _execTarget = if (_target isNotEqualTo false && {MON_GVAR(_monArg, _x, "CFM_isLocal", false)}) then {false} else {_target};
	_res = ["setScreenResolution", [_resolution], _execTarget, DEFAULT_SCREEN_RESOLUTION] REMOTE_EXEC_OBJINSTANCE("Monitor", _x, _monArg);
} forEach _keys;
_res
