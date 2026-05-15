/*
    Function: CFM_fnc_getTurretCameraLock
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_veh", ["_turret", [-1]]];

private _camLook = _veh lockedCameraTo _turret;
if (isNil "_camLook") then {
	_camLook = [0,0,0];
};
if (_camLook isEqualType objNull) then {
	_camLook = getPosASL _camLook;
};
if !(_camLook isEqualType []) then {
	_camLook = [0,0,0];
};
if (count _camLook != 3) then {
	_camLook = [0,0,0];
};
_camLook
