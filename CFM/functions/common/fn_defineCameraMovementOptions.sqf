/*
    Function: CFM_fnc_defineCameraMovementOptions
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_option", -1], ["_veh", objNull]];

private _defFalse = [false, []];
if (_option isEqualTo -1) exitWith {_defFalse};
if (_option isEqualTo 0) exitWith {_defFalse};
if (_option isEqualTo 1) exitWith {[true, []]};
if (_option isEqualTo true) exitWith {[true, []]};
if (_option isEqualTo false) exitWith {_defFalse};
if !(_option isEqualType []) exitWith {_defFalse};

private _option = (+_option) select {_x isEqualType 1};
private _sum = 0;
{
	_sum = _sum + _x;
} forEach _option;

if (_sum isEqualTo 0) exitWith {_defFalse};

_option params [["_leftDegrees", 0], ["_rightDegrees", 0], ["_upDegrees", 0], ["_downDegrees", 0]];

[true, [_leftDegrees, _rightDegrees, _upDegrees, _downDegrees]]
