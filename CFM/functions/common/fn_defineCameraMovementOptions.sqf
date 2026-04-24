/*
    Function: CFM_fnc_defineCameraMovementOptions
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_option", -1], ["_veh", objNull], ["_turret", -1]];

private _optionDefault = (_option isEqualTo -1);
private _optionIsTrue = (_option isEqualTo true);
private _doSet = false;
private _vehLimits = if (IS_OBJ(_veh)) then {
    private _cls = toLower typeOf _veh;
    if (IS_MAVIC(_cls)) exitWith {
        _doSet = _optionDefault || _optionIsTrue;
        [50, 90, 75, 75]
    };
    [30, 100, 180, 180] // 360 default
} else {[]};

private _defFalse = [_doSet, _vehLimits];
if (_optionDefault) exitWith {_defFalse};
if (_option isEqualTo 0) exitWith {_defFalse};
if (_option isEqualTo 1) exitWith {[true, _vehLimits]};
if (_optionIsTrue) exitWith {[true, _vehLimits]};
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
