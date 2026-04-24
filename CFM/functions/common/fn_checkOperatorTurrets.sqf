/*
    Function: CFM_fnc_checkOperatorTurrets
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator"];

private _hasActiveTurretsObjects = _operator getVariable ["CFM_hasActiveTurretsObjects", -1];

if (_hasActiveTurretsObjects isEqualTo -1) exitWith {-1};

private _activeTurretsObjects = _operator getVariable ["CFM_activeTurretsObjects", createHashMap];
private _aliveTurret = 0;
private ["_turretIndex", "_turretObj"];
{
	_turretIndex = _x;
	_turretObj = _y;
	if (IS_OBJ(_turretObj) && {alive _turretObj}) then {
		_aliveTurret = _aliveTurret + 1;
	} else {
		[_operator, _turretIndex] call CFM_fnc_removeActiveTurret;
	};
} forEach _activeTurretsObjects;
_operator setVariable ["CFM_hasActiveTurretsObjects", _aliveTurret, MONITOR_VIEWERS_AND_SELF(false)];

_aliveTurret
