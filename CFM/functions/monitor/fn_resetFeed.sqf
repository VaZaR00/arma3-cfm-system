/*
    Function: CFM_fnc_resetFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_turret", DRIVER_TURRET_PATH]];
private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
private _currTurret = _monitor getVariable ["CFM_currentTurret", _turret];
[_monitor, true] call CFM_fnc_stopOperatorFeed;
if !(IS_OBJ(_operator)) exitWith {};
private _hndl = _monitor getVariable ["CFM_monitorMainHndl", scriptNull];
if !(_hndl isEqualType scriptNull) then {
	_hndl = scriptNull;
};
waitUntil {scriptDone (_hndl)};
[_monitor, _operator, _currTurret, true] call CFM_fnc_startOperatorFeed;
