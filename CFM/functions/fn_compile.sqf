#include "defines.hpp" 

CFM_fnc_isUAVControlled = {
	params["_uav", ["_turret", "DRIVER"]];

	private _controls = UAVControl _uav;
	private _players = _controls select {IS_OBJ(_x) && {alive _x}};

	if (_players isEqualTo []) exitWith {false};

	_turret in _controls;
};

CFM_fnc_getPositionByVectors = {
    params [
		["_startPos", [0,0,0], [[]], [3]],
		["_vectorDir", [0,1,0], [[]], [3]],
		["_distance", 0, [0]]
	];

	// 1. Нормализуем вектор (приводим его длину к 1), чтобы избежать ошибок, 
	// если переданный вектор имеет произвольную длину.
	private _normalizedDir = vectorNormalized _vectorDir;

	// 2. Умножаем нормализованный вектор на нужную дистанцию.
	private _offset = _normalizedDir vectorMultiply _distance;

	// 3. Складываем начальную позицию с полученным смещением.
	private _finalPos = _startPos vectorAdd _offset;

	_finalPos
};

CFM_fnc_getObjCamOffsetMS = {
	params["_obj", ["_vectorMS", [0,0,0]], ["_dist", 1]];
	private _dir = _obj vectorModelToWorldVisual _vectorMS;
	private _pos = getPosASLVisual _obj;
	[_pos, _dir, _dist] call CFM_fnc_getPositionByVectors;
};

CFM_fnc_getTurretCameraLock = {
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
};

CFM_fnc_smoothRotateCam = {
	params["_veh", "_from", "_to"];

	_veh setPilotCameraDirection _to;
};

CFM_fnc_getVectorUpFromDir = {
	private _dir = _this;
	private _worldUp = [0, 0, 1];

	// Вычисляем вектор "вправо" относительно направления и мира
	private _right = _dir vectorCrossProduct _worldUp;

	// Если направление смотрит строго вверх или вниз, 
	// векторное произведение со [0,0,1] даст [0,0,0]. Нужно это учесть:
	if (vectorMagnitude _right == 0) then {
		_right = [1, 0, 0]; // Берем произвольную ось X
	};

	// Вычисляем финальный VectorUp
	private _up = _right vectorCrossProduct _dir;
	vectorNormalized _up
};