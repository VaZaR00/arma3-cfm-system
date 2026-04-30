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
	CFM_LocalActiveOperators = _activeOperators select {
		(local _x) && {
			private _hasTurrLocal = false;
			private _turretsParams = _operator getVariable "CFM_turretsParams";
			if (isNil "_turretsParams" || {!(_turretsParams isEqualType createHashMap)}) exitWith {false};
			{
				if (_y getOrDefault ["IsTurretLocal", false]) exitWith {
					_hasTurrLocal = true;
				};
			} forEach _turretsParams;
			_hasTurrLocal
		}
	};
	CFM_LocalActiveOperators
};

CFM_fnc_validatePointParams = {
	params[["_ppType", -1], ["_prevParams", []], ["_params", []]];

	#define VALID_VECTOR(vec) ((vec isEqualType []) && {(count vec) == 3})
	#define VALIDATE_VECTOR_SET_DEF(vec) if !(VALID_VECTOR(vec)) then {vec = [0,0,0]};

	switch (_ppType) do {
		case PP_STATIC: {
			_prevParams params [['_prevpos', []], ['_prevdir', []], ['_prevup', []]];
			_params params [['_pos', []], ['_dir', []], ['_up', []]];

			VALIDATE_VECTOR_SET_DEF(_prevpos)
			VALIDATE_VECTOR_SET_DEF(_prevdir)
			VALIDATE_VECTOR_SET_DEF(_prevup)

			if !(VALID_VECTOR(_pos)) then {
				_pos = +_prevpos;
			};
			if !(VALID_VECTOR(_dir)) then {
				_dir = +_prevdir;
			};
			if !(VALID_VECTOR(_up)) then {
				_up = +_prevup;
			};
			[_pos, _dir, _up]
		};
		case PP_VEH_STATIC: {
			_prevParams params [['_prevpos', []], ['_prevdir', []], ['_prevup', []]];
			_params params [['_pos', []], ['_dir', []], ['_up', []]];

			if ((_pos isEqualType "") || {(_pos#0) isEqualType ""}) then {
				// case if we need to convert params for PP_VEH_TURRET into PP_VEH_STATIC
				_params params[["_memPoint", ""], ["_addArr", []], ["_sdir", []], ["_sup", []], ["_setArr", []]];
				_pos = _addArr;
				_dir = _sdir;
				_up = _sup;
			};

			VALIDATE_VECTOR_SET_DEF(_prevpos)
			VALIDATE_VECTOR_SET_DEF(_prevdir)
			VALIDATE_VECTOR_SET_DEF(_prevup)

			if !(VALID_VECTOR(_pos)) then {
				_pos = +_prevpos;
			};
			if !(VALID_VECTOR(_dir)) then {
				_dir = +_prevdir;
			};
			if !(VALID_VECTOR(_up)) then {
				_up = +_prevup;
			};
			[_pos, [_dir, _up]]
		};
		case PP_VEH_TURRET: {
			_prevParams params [['_prevMemPoint', ""], ['_prevAlignment', []], ['_prevlod', "Memory"]];
			_prevAlignment params [["_prevAddArr", []], ["_prevDirUp", []], ["_prevSetArr", []]];
			_prevDirUp params [["_prevDir", []], ["_prevUp", []]];

			_params params[["_memPoint", ""], ["_addArr", []], ["_dir", []], ["_up", []], ["_setArr", []]];
			private _lod = "";

			if (_memPoint isEqualType []) then {
				_lod = _memPoint param [1,"memory"];
				_memPoint = _memPoint param [0,""];
			};

			if !(VALID_VECTOR(_prevSetArr)) then {_prevSetArr = [-1,-1,-1]};
			if !((_memPoint isEqualType "") && !(_memPoint isEqualTo "")) then {_prevMemPoint = ""};
			VALIDATE_VECTOR_SET_DEF(_prevAddArr)
			VALIDATE_VECTOR_SET_DEF(_prevDir)
			VALIDATE_VECTOR_SET_DEF(_prevUp)

			if !(VALID_VECTOR(_addArr)) then {
				_addArr = +_prevAddArr;
			};
			if !(VALID_VECTOR(_setArr)) then {
				_setArr = +_prevSetArr;
			};
			if !(VALID_VECTOR(_dir)) then {
				_dir = +_prevDir;
			};
			if !(VALID_VECTOR(_up)) then {
				_up = +_prevUp;
			};
			if !((_memPoint isEqualType "") && !(_memPoint isEqualTo "")) then {
				_memPoint = _prevMemPoint;
			};
			if !((_lod isEqualType "") && !(_lod isEqualTo "")) then {
				_lod = _prevlod;
			};
			[_memPoint, [_addArr, [_dir, _up], _setArr], _lod]
		};
		default {[]};
	};
};

CFM_fnc_getDefaultPointAlignment = {
	params["_objClass", ["_turrIndex", -1]];

	private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];

	private _predefinedAlignment = _pointSet get _objClass;

	if ((isNil "_predefinedAlignment") || {(_predefinedAlignment isEqualTo [])}) then {
		_predefinedAlignment = createHashMap;
	};
	if !(_predefinedAlignment isEqualType createHashMap) then {
		_predefinedAlignment = createHashMapFromArray _predefinedAlignment;
	};
	if ((isNil "_predefinedAlignment") || {!(_predefinedAlignment isEqualType createHashMap)}) then {
		_predefinedAlignment = createHashMap;
	};

	private _predefinedAlignmentTurr = _predefinedAlignment getOrDefault [_turrIndex, []];

	if (_predefinedAlignmentTurr isEqualType []) then {_predefinedAlignmentTurr} else {[]};
};