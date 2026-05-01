/*
    Function: CFM_fnc_timeInterpolate
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_prevValue", "_targetValue", ["_tightness", 0.01 max VALIDATE_NUM_VAR("CFM_camInterpolation_tightness", "5")], ["_dt", diag_deltaTime]];

// Формула затухания, независимая от FPS:
// Эффект = 1 - e^(-tightness * dt)
private _interpFactor = 1 - (exp (-_tightness * _dt));

if (_targetValue isEqualType []) exitWith {
	private _newValue = _prevValue vectorAdd ((_targetValue vectorDiff _prevValue) vectorMultiply _interpFactor);
	if ([_targetValue, _newValue, DO_INTERPOLATE_TOLERANCE] call CFM_fnc_compareVectors) then {
		_newValue = +_targetValue;
	};
	_newValue
};
if (_targetValue isEqualType 1) exitWith {
	private _newValue = _prevValue + ((_targetValue - _prevValue) * _interpFactor);
	if ((abs (_targetFov - _newFov)) < DO_INTERPOLATE_TOLERANCE) then {
		_newValue = _targetValue;
	};
	_newValue
};
_targetValue
