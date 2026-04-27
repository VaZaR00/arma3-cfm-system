/*
    Function: CFM_fnc_updateLocalOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _localOps = missionNamespace getVariable ["CFM_LocalActiveOperators", []];

private ["_op"];
{
	_op = _x;
	private _opTurrs = _op getVariable ["CFM_turrets", []];
	{
		[_op, _x] call CFM_fnc_updateOperator;
	} forEach _opTurrs;
} forEach _localOps;