/*
    Function: CFM_fnc_getPlayer
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_target", objNull]];

private _plr = PLAYER_;
private _currentPlrVeh = cameraOn;
private _res = if ((_target isEqualTo _plr) || {(vehicle _target) isEqualTo _currentPlrVeh}) then {
	if !(_currentPlrVeh isEqualTo _plr) exitWith {
		_plr
	};
	_currentPlrVeh
} else {
	_target
};

_res
