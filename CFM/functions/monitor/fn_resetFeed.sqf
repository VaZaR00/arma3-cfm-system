/*
    Function: CFM_fnc_resetFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_turret", DRIVER_TURRET_PATH]];

(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {};
private _monPair = [_monitor, _instId];

if !(MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) exitWith {
	[_monPair] call CFM_fnc_closePIPwindow;
};

isNil {
	[_monPair] call CFM_fnc_turnOffMonitorLocal;
};
private _hndl = MON_GVAR(_monitor, _instId, "CFM_monitorMainHndl", scriptNull);
if !(_hndl isEqualType scriptNull) then {
	_hndl = scriptNull;
};
waitUntil {scriptDone (_hndl)};
private _mainDisplay = MON_GVAR(_monitor, _instId, "CFM_mainDisplay", displayNull);
waitUntil {isNull (_mainDisplay)};
if !(MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) exitWith {};
isNil {
	[_monPair] call CFM_fnc_turnOnMonitorLocal;
};
