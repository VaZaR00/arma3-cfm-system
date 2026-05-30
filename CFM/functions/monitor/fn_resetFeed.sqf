/*
    Function: CFM_fnc_resetFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_turret", DRIVER_TURRET_PATH]];
isNil {
[_monitor] call CFM_fnc_turnOffMonitorLocal;
};
private _hndl = _monitor getVariable ["CFM_monitorMainHndl", scriptNull];
if !(_hndl isEqualType scriptNull) then {
	_hndl = scriptNull;
};
waitUntil {scriptDone (_hndl)};
private _mainDisplay = _monitor getVariable ["CFM_mainDisplay", displayNull];
waitUntil {isNull (_mainDisplay)};
isNil {
[_monitor] call CFM_fnc_turnOnMonitorLocal;
};