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

	private _nextVector = +_from;
	while {!([_nextVector, _to] call CFM_fnc_compareVectors)} do {
		sleep 0.01;
		_nextVector = +([_nextVector, _to, 8] call CFM_fnc_timeInterpolate);
		_veh setPilotCameraDirection _nextVector;
	};
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

CFM_fnc_getOperatorName = {
	params["_operator", ["_turret", -1]];
	["getOperatorName", [_turret], _operator, ""] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_getOperatorInfo = {
	params["_monitor"];
	["getOperatorInfo", [], _monitor, []] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_setOperatorInfo = {
	params["_monitor", ["_set", false]];
	["setOperatorInfo", [_set], _monitor, []] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_switchUAV = {
	params["_monitor"];
	["switchUAV"] SPAWN_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_setOperatorSides = {
	params["_operator", ["_sides", civilian]];
	["setOperatorSides", [_sides], _operator, false] SPAWN_OBJCLASS("Operator", _operator);
};

CFM_fnc_calculateCurrentCameraMoves = {
	params[["_initialDirUp", [[0,1,0], [0,0,1]]], ["_currentDirUp", [[0,1,0], [0,0,1]]]];

	if (_initialDirUp isEqualTo _currentDirUp) exitWith {[0,0,0,0]};

	private _initialDir = _initialDirUp select 0;
	private _initialUp = _initialDirUp select 1;
	private _currentDir = _currentDirUp select 0;
	private _currentUp = _currentDirUp select 1;

	private _worldZ = [0,0,1];

	private _initialFlat = [_initialDir select 0, _initialDir select 1, 0];
	private _currentFlat = [_currentDir select 0, _currentDir select 1, 0];

	private _yaw = 0;
	if ((vectorMagnitude _initialFlat > 0.001) && (vectorMagnitude _currentFlat > 0.001)) then {
		private _initialFlatN = vectorNormalized _initialFlat;
		private _currentFlatN = vectorNormalized _currentFlat;
		private _dotYaw = ((_initialFlatN vectorDotProduct _currentFlatN) min 1) max -1;
		private _signYaw = ((_initialFlatN vectorCrossProduct _currentFlatN) select 2);
		_yaw = acos _dotYaw;
		if (_signYaw < 0) then {_yaw = -_yaw};
	} else {
		private _initialDirN = vectorNormalized _initialDir;
		private _currentDirN = vectorNormalized _currentDir;
		private _dotYaw = ((_initialDirN vectorDotProduct _currentDirN) min 1) max -1;
		private _signYaw = ((_initialDirN vectorCrossProduct _currentDirN) select 2);
		_yaw = acos _dotYaw;
		if (_signYaw < 0) then {_yaw = -_yaw};
	};

	private _rotDir = [_initialDir, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
	private _rotUp = [_initialUp, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
	private _side = _rotDir vectorCrossProduct _rotUp;
	if (vectorMagnitude _side == 0) then {_side = [1,0,0]};

	private _rotDirN = vectorNormalized _rotDir;
	private _currentDirN = vectorNormalized _currentDir;
	private _dotPitch = ((_rotDirN vectorDotProduct _currentDirN) min 1) max -1;
	private _pitch = acos _dotPitch;
	private _signPitch = ((_rotDirN vectorCrossProduct _currentDirN) vectorDotProduct _side);
	if (_signPitch < 0) then {_pitch = -_pitch};

	private _degPitch = _pitch;
	private _degYaw = _yaw;

	[_degPitch, -_degPitch, _degYaw, -_degYaw]
};

CFM_fnc_calculateCameraMoves = {
	params[["_currentMoves", [0,0,0,0], [[]], 4], ["_moves", [0,0], [[]], 2], ["_restrictions", [0,0,0,0], [[]], 4]];

	_moves params [["_horizontal", 0], ["_vertical", 0]];

	private _proccessDirection = {
		params["_currMove", "_restr", "_move"];
		private _newMove = _currMove + _move;
		if (_restr == 0) then {
			_restr = 180
		};
		if ((_newMove >= 180) && {_restr >= 180}) exitWith {
			0
		};
		if ((_currMove < _restr) && {_newMove > _restr}) then {
			_newMove = _restr;
		};
		_newMove
	};

	private _vertUp = [(_currentMoves#0), (_restrictions#0), _vertical] call _proccessDirection;
	private _vertDown = [(_currentMoves#1), (_restrictions#1), -_vertical] call _proccessDirection;
	private _horizLeft = [(_currentMoves#2), (_restrictions#2), _horizontal] call _proccessDirection;
	private _horizRight = [(_currentMoves#3), (_restrictions#3), -_horizontal] call _proccessDirection;

	[_vertUp, _vertDown, _horizLeft, _horizRight]
};

CFM_fnc_checkIfOperatorFeedsToAnyMonitor = {
	params["_operator"];
	["checkIfFeedsToAnyMonitor", [], _operator, false] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_setupLocalActiveOperators = {
	private _activeOperators = missionNamespace getVariable ["CFM_ActiveOperators", []];
	CFM_LocalActiveOperators = _activeOperators select {local _x};
	CFM_LocalActiveOperators
};

CFM_fnc_validateSetPointParams = {
	params["_turretParams", "_pointParams", ["_func", -1]];

	_func = if (_func isEqualType {}) then {_func} else {
		_turretParams getOrDefault ["camPosFunc", {}];
	};

	private _checkedPointParams = +_pointParams;
	switch (_func) do {
		case CFM_fnc_camPosVehStatic: {
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				if ((count _pointParams) != 2) exitWith {false};
				_pointParams params [["_m", ""], ["_offsets", []]];
				if !(_offsets isEqualType []) exitWith {false};
				_offsets params [["_pos", []], ["_vdup", []]];
				if !(_pos isEqualType []) exitWith {false};
				if (count _pos != 3) exitWith {false};
				if !(_vdup isEqualType []) exitWith {
					_checkedPointParams = [_m, [_pos, [NULL_VECTOR, NULL_VECTOR]]];
					true
				};
				_vdup params [["_dir", []], ["_up", []]];
				if (!(_dir isEqualType []) || {(count _dir != 3)}) then {
					_dir = NULL_VECTOR;
				};
				if (!(_up isEqualType []) || {(count _up != 3)}) then {
					_up = NULL_VECTOR;
				};
				_checkedPointParams = [_m, [_pos, [_dir, _up]]];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = ["", [NULL_VECTOR, [NULL_VECTOR, NULL_VECTOR]]];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
		case CFM_fnc_camPosVehTurret: {
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				_pointParams params [["_memPoint", []], ["_align", []]];
				if !(_memPoint isEqualType "") then {
					_memPoint = "";
				};
				private _defAdd = [0,0,0];
				private _defSet = [-1,-1,-1];
				private _defAddSet = [+_defAdd, +_defSet];
				if (!(_align isEqualType []) || {(_align isEqualTo [])}) exitWith {
					_checkedPointParams = [_memPoint, +_defAddSet];
					true
				};
				_align params [["_add", []], ["_set", []]];
				if (!(_add isEqualType []) || {(count _add != 3)}) then {
					_add = +_defAdd;
				};
				if (!(_set isEqualType []) || {(count _set != 3)}) then {
					_set = +_defSet;
				};
				_checkedPointParams = [_memPoint, [_add, _set]];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = ["", [NULL_VECTOR, NULL_VECTOR]];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
		case CFM_fnc_camPosStatic: {
			private _checkPointParams = call {
				if !(_pointParams isEqualType []) exitWith {false};
				_pointParams params [["_pos", []], ["_dir", []], ["_up", []]];
				if (!(_pos isEqualType []) || {(count _pos != 3)}) then {
					_pos = NULL_VECTOR;
				};
				if (!(_dir isEqualType []) || {(count _dir != 3)}) then {
					_dir = NULL_VECTOR;
				};
				if (!(_up isEqualType []) || {(count _up != 3)}) then {
					_up = NULL_VECTOR;
				};
				_checkedPointParams = [_pos, _dir, _up];
				true
			};
			if !(_checkPointParams) then {
				_pointParams = [NULL_VECTOR, NULL_VECTOR, NULL_VECTOR];
			} else {
				_pointParams = +_checkedPointParams;
			};
		};
	};

	_turretParams set ["pointParams", _pointParams];

	_pointParams
};