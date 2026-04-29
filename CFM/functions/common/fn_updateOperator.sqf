/*
    Function: CFM_fnc_updateOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[
	["_operator", objNull]
];

private _opTurrs = _operator getVariable ["CFM_turrets", []];
{
	[_operator, _x] call CFM_fnc_updateTurretCamera;
} forEach _opTurrs;
