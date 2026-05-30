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
    if !((local _operator) || {_operator call CFM_fnc_checkTurretsLocality}) then {
        _localityChanged = true;
        continue
    };
    if (_turrets isEqualTo []) then {continue};
    {
        [_operator, _x] call CFM_fnc_updateTurretCamera;
    } forEach _turrets;
} forEach _localOps;