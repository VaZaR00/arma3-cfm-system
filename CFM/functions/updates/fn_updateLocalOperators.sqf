/*
    Function: CFM_fnc_updateLocalOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

// periodically re-check turrets locality on every machine (incl. server): turret locality can change
// without any event (e.g. remote control released -> turret goes back to vehicle owner)
if ((diag_tickTime - (missionNamespace getVariable ["CFM_lastLocalTurretsCheck", 0])) >= (MGVAR ["CFM_AdditionalLocalTurretsCheckInterval", 1])) then {
	missionNamespace setVariable ["CFM_lastLocalTurretsCheck", diag_tickTime];
	if ((missionNamespace getVariable ["CFM_ActiveOperators", []]) isNotEqualTo []) then {
		[] call CFM_fnc_updateActiveOperatorsLocalTurrets;
	};
};

private _localOps = missionNamespace getVariable ["CFM_LocalActiveOperators", []];

private _localityChanged = false;
{
    _x params [["_operator", objNull], ["_turrets", []]];
    if (_turrets isEqualTo []) then {continue};
    {
        private _turret = if (_x isEqualType []) then {_x} else {[_x]};
        if !(_operator turretLocal _turret) then {continue};
        [_operator, _turret] call CFM_fnc_updateTurretCamera;
    } forEach _turrets;
} forEach _localOps;