/*
    Function: CFM_fnc_updateLocalOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

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