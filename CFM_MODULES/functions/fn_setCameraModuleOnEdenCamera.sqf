/*
	Function: CFM_fnc_setCameraModuleOnEdenCamera

	Author: Vazar, Gemini

	Description:
		Creates or Sets selected "CFM_Module_Camera" module entity in the 3DEN editor
		at the exact position and orientation (direction and up vectors) of the current 3DEN camera.

	Return Value:
		<OBJECT> - Created 3DEN module entity, or objNull if executed outside 3DEN.

*/

#include "defines.hpp"


if (!is3DEN) exitWith { objNull };

private _cam = get3DENCamera;
if (isNull _cam) exitWith { objNull };

private _class = "CFM_Module_Camera";
private _camPosATL = getPosATLVisual _cam;

private _selected = (get3DENSelected "logic") param [0, objNull];
private _module = if ((typeOf _selected) isEqualTo _class) then {
    _selected
} else {
    create3DENEntity ["Logic", _class, _camPosATL];
};

private _vectorDirAndUpTo3DENRotation = {
	params ["_vDir", "_vUp"];

	// Вычисляем вектор Right (ось X объекта) через крестное произведение Dir x Up
	private _vRight = _vDir vectorCrossProduct _vUp;

	private _rx = _vRight select 0;
	private _ry = _vRight select 1;

	private _dx = _vDir select 0;
	private _dy = _vDir select 1;

	private _ux = _vUp select 0;
	private _uy = _vUp select 1;
	private _uz = _vUp select 2;

	private _pitch = 0;
	private _bank = 0;
	private _yaw = 0;

	// Клампим _ux в диапазон [-1, 1], чтобы избежать ошибок точности float в asin
	private _sinBank = (-_ux) max -1 min 1;
	_bank = asin _sinBank;

	// Проверка на шарнирный замок (Gimbal Lock при банке +-90 градусов)
	if (abs _ux > 0.999999) then {
		_pitch = 0;
		if (_ux > 0) then {
			_yaw = (-_ry) atan2 _dy;
		} else {
			_yaw = _ry atan2 _dy;
		};
	} else {
		_pitch = _uy atan2 _uz;
		_yaw   = _dx atan2 _rx;
	};

	// Нормализация углов в диапазон [0, 360)
	_pitch = (_pitch % 360 + 360) % 360;
	_bank  = (_bank % 360 + 360) % 360;
	_yaw   = (_yaw % 360 + 360) % 360;

	[_pitch, _bank, _yaw]
};
#ifdef DEV
fnc_vectorDirAndUpTo3DENRotation = _vectorDirAndUpTo3DENRotation;
#endif

if (!isNull _module) then {
    private _vDirUp = [vectorDir _cam, vectorUp _cam];
    private _rotation = _vDirUp call _vectorDirAndUpTo3DENRotation;

    collect3DENHistory {
        _module set3DENAttribute ["position", _camPosATL];
        _module set3DENAttribute ["rotation", _rotation];
        _module set3DENLayer -1;
    };
    
    [format["Module Position Set"]] call BIS_fnc_3DENNotification;
    
    set3DENSelected [_module];
};

_module