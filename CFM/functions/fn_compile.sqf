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
		["_vectorDir", DEF_DIR, [[]], [3]],
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
	["getOperatorName", [_turret], ""] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_getOperatorInfo = {
	params["_monitor"];
	["getOperatorInfo", [], []] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_setOperatorInfo = {
	params["_monitor", ["_set", false]];
	["setOperatorInfo", [_set], []] CALL_OBJCLASS("Monitor", _monitor);
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
	["checkIfFeedsToAnyMonitor", [], false] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_setupLocalActiveOperators = {
	private _activeOperators = missionNamespace getVariable ["CFM_ActiveOperators", []];
	CFM_LocalActiveOperators = _activeOperators select {
		(local _x) && {
			private _hasTurrLocal = false;
			private _turretsParams = _x getVariable "CFM_turretsParams";
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

CFM_fnc_turretChangedLocalOperator = {
	params["_operator", "_monitor", ["_turret", -1]];
	["TurretChangedLocalOperator", [_monitor, _turret]] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_operatorMonitorConnectedEvent = {
	params["_operator", "_monitor", ["_turret", -1]];
	["monitorConnectedLocalOperator", [_monitor, _turret]] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_operatorMonitorDisconnectedEvent = {
	params["_operator", "_monitor", ["_turret", -1]];
	["monitorDisconnectedLocalOperator", [_monitor, _turret]] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_operatorsLocalityChangedEvent = {
    publicVariable "CFM_ActiveOperators";
    call CFM_ActiveOperators_PublicEH;
};

CFM_fnc_validatePointParams = {
	params[["_ppType", -1], ["_prevParams", []], ["_params", []]];

	#define VALID_VECTOR(vec) ((vec isEqualType []) && {(count vec) == 3})
	#define VALIDATE_VECTOR_SET_DEF(vec) if !(VALID_VECTOR(vec)) then {vec = [0,0,0]};
	#define VALIDATE_VECTOR_SET_DEF_DIR(vec) if !(VALID_VECTOR(vec)) then {vec = DEF_DIR};
	#define VALIDATE_VECTOR_SET_DEF_UP(vec) if !(VALID_VECTOR(vec)) then {vec = DEF_UP};

	switch (_ppType) do {
		case PP_STATIC: {
			_prevParams params [['_prevpos', []], ['_prevdir', []], ['_prevup', []]];
			_params params [['_pos', []], ['_dir', []], ['_up', []]];

			VALIDATE_VECTOR_SET_DEF(_prevpos)
			VALIDATE_VECTOR_SET_DEF_DIR(_prevdir)
			VALIDATE_VECTOR_SET_DEF_UP(_prevup)

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
			VALIDATE_VECTOR_SET_DEF_DIR(_prevdir)
			VALIDATE_VECTOR_SET_DEF_UP(_prevup)

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
			VALIDATE_VECTOR_SET_DEF_DIR(_prevDir)
			VALIDATE_VECTOR_SET_DEF_UP(_prevUp)

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

CFM_fnc_translateLocalVectors = {
	params ["_dirUp1", "_dirUp2"];
	_dirUp1 params ["_dir1", "_up1"];
	_dirUp2 params ["_dir2", "_up2"];

	// 1. Вычисляем базисные векторы первой системы (DirUp1)
	private _yAxis = _dir1;
	private _zAxis = _up1;
	private _xAxis = _yAxis vectorCrossProduct _zAxis; // Ось X (право)

	// 2. Функция для перевода вектора из локала DirUp1 в Model Space
	// Формула: V_world = (X * V_local.x) + (Y * V_local.y) + (Z * V_local.z)
	private _transformVector = {
		params ["_v", "_x", "_y", "_z"];
		private _res = [0,0,0];
		_res = _res vectorAdd (_x vectorMultiply (_v select 0));
		_res = _res vectorAdd (_y vectorMultiply (_v select 1));
		_res = _res vectorAdd (_z vectorMultiply (_v select 2));
		_res
	};

	// 3. Применяем трансформацию для Dir2 и Up2
	private _finalDir = [_dir2, _xAxis, _yAxis, _zAxis] call _transformVector;
	private _finalUp = [_up2, _xAxis, _yAxis, _zAxis] call _transformVector;

	// Нормализуем для порядка (хотя векторные команды часто делают это сами)
	_finalDir = vectorNormalized _finalDir;
	_finalUp = vectorNormalized _finalUp;

	// Результат: [_finalDir, _finalUp]
	[_finalDir, _finalUp]
};

// Keybinds
#define GET_MON (call CFM_fnc_getTargetMonitor)
CFM_fnc_zoomInKeybind = {
	[GET_MON, 1] call CFM_fnc_zoom;
};
CFM_fnc_zoomOutKeybind = {
	[GET_MON, -1] call CFM_fnc_zoom;
};
CFM_fnc_zoomResetKeybind = {
	[GET_MON, "reset"] call CFM_fnc_zoom;
};
CFM_fnc_zoomOperatorKeybind = {
	[GET_MON, "op"] call CFM_fnc_zoom;
};
CFM_fnc_exitFullscreenKeybind = {
	call CFM_fnc_onTempDisplayUnload;
};
CFM_fnc_takeUavCtrlKeybind = {
	[GET_MON] spawn CFM_fnc_takeUAVcontorls;
};
CFM_fnc_nextTurretKeybind = {
	private _monitor = GET_MON;
	if !(_monitor call CFM_fnc_switchCameraTurretActionCondition) exitWith {};
	[_monitor] call CFM_fnc_monitorNextTurretCamera;
};
CFM_fnc_monitorSwitchTIKeybind = {
	private _monitor = GET_MON;
	if !(_monitor call CFM_fnc_toggleTiActionCondition) exitWith {};
	[_monitor] call CFM_fnc_monitorSwitchTi;
};
CFM_fnc_monitorSwitchNVGKeybind = {
	private _monitor = GET_MON;
	if !(_monitor call CFM_fnc_toggleNvgActionCondition) exitWith {};
	[_monitor] call CFM_fnc_monitorToggleNVG;
};
CFM_fnc_cameraTurnUpKeybind = {
	[GET_MON] call CFM_fnc_monitorCameraTurnUp;
};
CFM_fnc_cameraTurnDownKeybind = {
	[GET_MON] call CFM_fnc_monitorCameraTurnDown;
};
CFM_fnc_cameraTurnRightKeybind = {
	[GET_MON] call CFM_fnc_monitorCameraTurnRight;
};
CFM_fnc_cameraTurnLeftKeybind = {
	[GET_MON] call CFM_fnc_monitorCameraTurnLeft;
};

CFM_fnc_randInt = {
    params ["_x", "_y", "_r", "_M"];
    // Добавляем больше "перемешивания" бит через циклическое умножение
    private _val = sin (_x * 2.9898 + _y * 1.223 + _r * 0.123);
    _val = _val * 558.5453;
    private _frac = _val - floor _val;
    _M * _frac
};

CFM_fnc_defineInterfaceData = {
	// returns [_interfaceClass, _interfaceFuncNameDef, _interfaceInitFuncNameDef]
	params["_operator", ["_turret", -1], ["_opClass", ""], ["_isMavic", false], ["_isFPV", false], ["_isDrone", false]];

	if !(IS_STR(_opClass)) then {
		_opClass = toLower typeOf _operator;
	};

	if (_isMavic) exitWith {
		["RscCFM_Mavic_Interface", MGVAR ["CFM_fnc_updateMavicInterface", {}], MGVAR ["CFM_fnc_initMavicInterface", {}]]
	};
	if (_isFPV) exitWith {
		["RscCFM_ArmaFPV_Dialog", MGVAR ["CFM_fnc_updateFPVInterface", {}], MGVAR ["CFM_fnc_initFPVInterface", {}]]
	};
	if ("zala" in _opClass) exitWith {
		switch (_turret) do {
			// case DRIVER_TURRET_IDX: {
			// 	['CFM_Zala421_Interface_Driver', MGVAR ["CFM_fnc_zala_drawHudDriver", {}], MGVAR ["CFM_fnc_initZalaInterfaceDriver", {}]]
			// };
			case GUNNER_TURRET_IDX: {
				['CFM_Zala421_Interface_Gunner', MGVAR ["CFM_fnc_zala_drawHudGunner", {}], MGVAR ["CFM_fnc_initZalaInterfaceGunner", {}]]
			};
			default {[]};
		};
	};
	if (_isDrone) exitWith {
		["RscDisplayR2TDisplayCFM", MGVAR ["CFM_fnc_drone_updateInterface", {}], MGVAR ["CFM_fnc_drone_initInterface", {}]]
	};

	[]
};

CFM_fnc_defineSignalEffectFunc = {
	// returns [signalFunc, effectFunc]
	params["_operator", ["_turret", -1], ["_opClass", ""], ["_isMavic", false], ["_isFPV", false], ["_isDrone", false]];

	if (_isFPV) exitWith {
		[MGVAR ["CFM_fnc_fpv_getSignal", {1}], MGVAR ["CFM_fnc_fpv_effects", {}]]
	};
	if (_isDrone) exitWith {
		[MGVAR ["CFM_fnc_drone_getSignal", {1}], MGVAR ["CFM_fnc_drone_effects", {}]]
	};

	[]
};

// effects
CFM_fnc_signalFunc = {
	params["_monitor", "_operator", ["_signalFunc", {}]];

	_this call _signalFunc;
};

CFM_fnc_interfaceFunc = {
	params["_monitor", "_operator", "_signal", "_mainDisplay", "_uiDisplayUniqueName", ["_interfaceFunc", {}]];
	
	_this call _interfaceFunc;
};

CFM_fnc_effectsFunc = {
	params["_monitor", "_operator", "_effectsLayersControls", ["_effectsFunc", {}]];
	
	_this call _effectsFunc;
};

CFM_fnc_radioNoiseEffect = {
	params[["_signal", 1], ["_effectLayerCtrl", controlNull], ["_effectAdjust", 1]];
	
	private _serverTime = serverTime;
	private _intX = _serverTime - (_serverTime - ((_serverTime mod 20)));
	private _randInt1 = [_signal - 0.1, (-_intX - 1), -_signal, 220] call CFM_fnc_randInt;
	private _randInt2 = [-_signal + 1, _intX, _signal + 2, 220] call CFM_fnc_randInt;
	private _effectStrenght = (((1 - _signal) max 0) * 2) * _effectAdjust;

	_effectLayerCtrl ctrlSetText (format["#(ai,128,128,1)perlinNoise(%2,%3,0,%1)", _effectStrenght, _randInt1, _randInt2]);
};


// Drone
CFM_fnc_drone_initInterface = {
	params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

	[DISP_CTRL 1488, [DISP_CTRL 1489]]
};

CFM_fnc_drone_updateInterface = {
	// params[["_monitor", objNull], ["_operator", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

};

CFM_fnc_drone_effects = {
	call CFM_fnc_drone_checkRebEffect
};

CFM_fnc_drone_checkRebEffect = {
	params[["_uav", objNull], ["_signal", 1], ["_ctrlsLayers", []]];

	private _rebStrenght = _uav getVariable ["REB_uavActiveRebStrength", 0];

	if !((_uav getVariable ["REB_uavIsSuppressed", false]) || {
		private _lastTimeChecked = _uav getVariable ["CFM_REB_suppressedCheckLastTime", 0];
		if ((diag_tickTime - _lastTimeChecked) > 1) then {
			_uav setVariable ["CFM_REB_suppressedCheckLastTime", diag_tickTime];
			_rebStrenght = _uav call REB_fnc_currentJammingRebStrength;
		};
		_uav setVariable ["REB_uavActiveRebStrength", _rebStrenght];
		_rebStrenght > 0
	}) exitWith {false};

	private _signal = (1 - _rebStrenght) / 20;

	[_signal, _ctrlsLayers param [0, controlNull], 1] call CFM_fnc_radioNoiseEffect;
	true
};

// Mavic
CFM_fnc_updateMavicInterface = {
	params[["_monitor", objNull], ["_operator", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

	private _pilot = _monitor;
	private _uav = _operator;

	private _batteryPicture = uiNameSpace getVariable ["DB_mavic_batteryPicture" + _uiDisplayUniqueName, controlNull];
	private _batteryText = uiNameSpace getVariable ["DB_mavic_batteryText" + _uiDisplayUniqueName, controlNull];

	private _currentBattery = fuel _uav;
	private _batteryPictureSet = "\mavik\interface\bat\25.paa";
	private _textColor = [0.298039, 0.733334, 0.564706, 1];

	switch (true) do {
		case (_currentBattery > 0.75): {
			_batteryPictureSet = "\mavik\interface\bat\100.paa";
			_textColor = [0.298039, 0.733334, 0.564706, 1];
		};
		case (_currentBattery > 0.5): {
			_batteryPictureSet = "\mavik\interface\bat\75.paa";
			_textColor = [0.298039, 0.733334, 0.564706, 1];
		};
		case (_currentBattery > 0.25): {
			_batteryPictureSet = "\mavik\interface\bat\50.paa";
			_textColor = [0.976471, 0.541177, 0.082353, 1];
		};
		default {
			_batteryPictureSet = "\mavik\interface\bat\25.paa";
			_textColor = [0.929412, 0.196078, 0.145098, 1];
		};
	};

	_batteryPicture ctrlSetText _batteryPictureSet;
	_batteryText ctrlSetText str(floor (_currentBattery * 100));
	_batteryText ctrlSetTextColor _textColor;


	private _remainingTimeText = uiNameSpace getVariable ["DB_mavic_RemainingTimeText" + _uiDisplayUniqueName, controlNull];
	private _maxFlightTime = 30; 

	private _remainingFlightTimeMinutes = _maxFlightTime * _currentBattery;
	private _remainingFlightTimeSeconds = _remainingFlightTimeMinutes * 60;
	private _minutes = floor(_remainingFlightTimeSeconds / 60);
	private _seconds = floor(_remainingFlightTimeSeconds % 60);

	private _formattedSeconds = [format ["%1", _seconds], format ["0%1", _seconds]] select (_seconds < 10);

	_remainingTimeText ctrlSetText format ["%1'%2""", _minutes, _formattedSeconds];

	private _signalControl = uiNameSpace getVariable ["DB_mavic_SignalText" + _uiDisplayUniqueName, controlNull];
	private _signalPictureSet = "\mavik\interface\signal\0.paa";

	switch (true) do {
		case (_signal > 0.8): {
			_signalPictureSet = "\mavik\interface\signal\100.paa";
		};
		case (_signal > 0.6): {
			_signalPictureSet = "\mavik\interface\signal\80.paa";
		};
		case (_signal > 0.4): {
			_signalPictureSet = "\mavik\interface\signal\60.paa";
		};
		case (_signal > 0.2): {
			_signalPictureSet = "\mavik\interface\signal\40.paa";
		};
		case (_signal > 0): {
			_signalPictureSet = "\mavik\interface\signal\20.paa";
		};
		default {
			_signalPictureSet = "\mavik\interface\signal\0.paa";
		};
	};

	_signalControl ctrlSetText _signalPictureSet;


	private _satelitePicture = uiNameSpace getVariable ["DB_mavic_SatellitePicture" + _uiDisplayUniqueName, controlNull];

	_satelitePicture ctrlSetText (["\mavik\interface\main\sat100.paa", "\mavik\interface\main\sat0.paa"] select (_signal < 0.6));


	private _statusText = uiNameSpace getVariable ["DB_mavic_FlightStatus_Text" + _uiDisplayUniqueName, controlNull];

	_statusText ctrlSetText ([localize "STR_mavic_flightStatus_Flight", localize "STR_mavic_flightStatus_Ground"] select (isTouchingGround _uav));


	private _vSpeedText = uiNameSpace getVariable ["DB_mavic_VSpeed_control" + _uiDisplayUniqueName, controlNull];
	private _hSpeedText = uiNameSpace getVariable ["DB_mavic_HSpeed_control" + _uiDisplayUniqueName, controlNull];

	_vSpeedText ctrlSetText format ["%1 %2", floor((speed _uav) / 3.6), localize "STR_mavic_metersSeconds"];
	_hSpeedText ctrlSetText format ["%1 %2", floor((velocityModelSpace _uav) # 2), localize "STR_mavic_metersSeconds"];

	private _heightText = uiNameSpace getVariable ["DB_mavic_Height_control" + _uiDisplayUniqueName, controlNull];
	_heightText ctrlSetText format["%1 %2", floor(_uav call CBA_fnc_realHeight), localize "STR_mavic_meters"];

	private _distanceText = uiNameSpace getVariable ["DB_mavic_Distance_control" + _uiDisplayUniqueName, controlNull];
	_distanceText ctrlSetText format["%1 %2", floor(_pilot distance _uav), localize "STR_mavic_meters"];


	private _zoomText = uiNameSpace getVariable ["DB_mavic_Zoom_Text" + _uiDisplayUniqueName, controlNull];
	private _maxFov = getNumber (configFile >> "CfgVehicles" >> (typeOf _uav) >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "maxFov");
	private _currentFov = getObjectFov _uav;
	if (_currentFov == 0) then {_currentFov == 1};
	private _zoom = floor(_maxFov/_currentFov);
	_zoomText ctrlSetText format ["%1x", _zoom];

	// if !(isNil "DB_PP_dynamic") then { DB_PP_dynamic ppEffectEnable false; };

	// switch true do {
	// 	case (_zoom < 7): {
	// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
	// 		DB_PP_dynamic ppEffectEnable true;
	// 		DB_PP_dynamic ppEffectAdjust [0.1];
	// 		DB_PP_dynamic ppEffectCommit 0; 
	// 	};

	// 	case (_zoom < 14): {
	// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
	// 		DB_PP_dynamic ppEffectEnable true;
	// 		DB_PP_dynamic ppEffectAdjust [0.3];
	// 		DB_PP_dynamic ppEffectCommit 0; 
	// 	};

	// 	case (_zoom <= 28): {
	// 		DB_PP_dynamic = ppEffectCreate ["DynamicBlur",500];
	// 		DB_PP_dynamic ppEffectEnable true;
	// 		DB_PP_dynamic ppEffectAdjust [0.5];
	// 		DB_PP_dynamic ppEffectCommit 0; 
	// 	};
	// }; 
};

CFM_fnc_initMavicInterface = {
	params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

	GET_CTRL("DB_mavic_batteryPicture", 689)
	GET_CTRL("DB_mavic_batteryText", 635)
	GET_CTRL("DB_mavic_RemainingTimeText", 653)
	GET_CTRL("DB_mavic_SignalText", 624)
	GET_CTRL("DB_mavic_SatellitePicture", 385)
	GET_CTRL("DB_mavic_FlightStatus_Text", 824)
	GET_CTRL("DB_mavic_VSpeed_control", 375)
	GET_CTRL("DB_mavic_HSpeed_control", 952)
	GET_CTRL("DB_mavic_Height_control", 214)
	GET_CTRL("DB_mavic_Distance_control", 458)
	GET_CTRL("DB_mavic_Zoom_Text", 278)
	GET_CTRL("DB_mavic_R2TPicture", 1488)
	GET_CTRL("DB_mavic_EffectPicture", 1489)

	[_display displayCtrl 1488, [DISP_CTRL 1489]]
};

// FPV
CFM_fnc_updateFPVInterface = {
	params[["_monitor", objNull], ["_operator", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

	private _OnTimeTextCtrl = uiNameSpace getVariable ["ArmaFPV_OnTimeText" + _uiDisplayUniqueName, controlNull];
	private _SignalPictureCtrl = uiNameSpace getVariable ["ArmaFPV_SignalPicture" + _uiDisplayUniqueName, controlNull];
	private _SignalTextCtrl = uiNameSpace getVariable ["ArmaFPV_SignalText" + _uiDisplayUniqueName, controlNull];
	private _BatteryPictureCtrl = uiNameSpace getVariable ["ArmaFPV_BatteryPicture" + _uiDisplayUniqueName, controlNull];
	private _BatteryTextCtrl = uiNameSpace getVariable ["ArmaFPV_BatteryText" + _uiDisplayUniqueName, controlNull];

	[_operator, _BatteryPictureCtrl, _BatteryTextCtrl] call CFM_fnc_fpv_handleBattery;
	[_operator, _signal, _SignalPictureCtrl, _SignalTextCtrl] call CFM_fnc_fpv_handleSignal;
};

CFM_fnc_initFPVInterface = {
	params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

	GET_CTRL("ArmaFPV_OnTimeText", 237)
	GET_CTRL("ArmaFPV_SignalPicture", 825)
	GET_CTRL("ArmaFPV_SignalText", 836)
	GET_CTRL("ArmaFPV_BatteryPicture", 241)
	GET_CTRL("ArmaFPV_BatteryText", 369)

	[_display displayCtrl 1488, [_display displayCtrl 1489, _display displayCtrl 1490]]
};

CFM_fnc_fpv_getSignal = {
	params["_monitor", "_operator"];
	if !(_operator getVariable ["ArmaFPV_simulateSignal", missionNamespace getVariable ["ArmaFPV_simulateSignal", true]]) exitWith {1};
	[_monitor, _operator] call DB_fnc_fpv_getSignal;
};

CFM_fnc_fpv_effects = {
	if (call CFM_fnc_drone_checkRebEffect) exitWith {};

	params[["_uav", objNull], ["_signal", 1], ["_ctrlsLayers", []]];

	if (_uav getVariable ["ArmaFPV_effectOff", missionNamespace getVariable ["ArmaFPV_effectOff", false]]) exitWith {};

	private _effectAdjust = _uav getVariable ["ArmaFPV_effectAdjust", missionNamespace getVariable ["ArmaFPV_effectAdjust", 1]];

	if (_effectAdjust <= 0) exitWith {};

	[_signal, _ctrlsLayers param [0, controlNull], _effectAdjust] call CFM_fnc_radioNoiseEffect;

	private _serverTime = serverTime;
	private _intX = _serverTime - (_serverTime - ((_serverTime mod 20)));
	private _randInt1 = [_signal - 0.1, (-_intX - 1), -_signal, 220] call CFM_fnc_randInt;
	(_ctrlsLayers param [1, controlNull]) ctrlSetText (format["#(rgb,8,8,3)color(1,0.4,0.1,%1)", (_randInt1 / 220) * 0.05]);
};

CFM_fnc_fpv_handleTime = {
	_thisArgs params ["_startTime", "_uav"];
	private _timeElapsed = time - _startTime;
	
	private _controlText = uiNameSpace getVariable ["ArmaFPV_OnTimeText", controlNull];
	_controlText ctrlSetText ([_timeElapsed, "MM:SS"] call BIS_fnc_secondsToString);

	// Обновляем сохраненное время
	_uav setVariable ["DB_fpv_savedTime", _timeElapsed, true];

	if !(missionNamespace getVariable ["ArmaFPV_isControl", false]) exitWith {
		removeMissionEventHandler ["EachFrame", _thisEventHandler];
	};
};

CFM_fnc_fpv_handleBattery = {
	params["_uav", "_controlPicture", "_controlText"];

	private _currentBattery = fuel _uav;

	private _picture = "";

	switch (true) do {
		case (_currentBattery > 0.75): { _picture = "\fpv_ua\pictures\A100.paa" };
		case (_currentBattery > 0.5): { _picture = "\fpv_ua\pictures\A75.paa" };
		case (_currentBattery > 0.25): { _picture = "\fpv_ua\pictures\A50.paa" };
		case (_currentBattery > 0): { _picture = "\fpv_ua\pictures\A25.paa" };
		case (_currentBattery <= 0): { _picture = "\fpv_ua\pictures\A0.paa" };
		default { _picture = "\fpv_ua\pictures\A75.paa" };
	};

	_controlPicture ctrlSetText _picture;
	_controlText ctrlSetText str(round(_currentBattery * 100));
};

CFM_fnc_fpv_handleSignal = {
	params["_uav", "_signal", "_controlPicture", "_controlText"];

	private _picture = "";

	switch (true) do {
		case (_signal > 0.75): { _picture = "\fpv_ua\pictures\100.paa"; };
		case (_signal > 0.5): { _picture = "\fpv_ua\pictures\75.paa" };
		case (_signal > 0.25): { _picture = "\fpv_ua\pictures\50.paa" };
		case (_signal > 0): { _picture = "\fpv_ua\pictures\25.paa" };
		case (_signal <= 0): { _picture = "\fpv_ua\pictures\0.paa" };
		default { _picture = "\fpv_ua\pictures\100.paa" };
	};

	_controlPicture ctrlSetText _picture;
	_controlText ctrlSetText str(round(_signal * 100));
};

// Zala
CFM_fnc_initZalaInterfaceDriver = {
	params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

	GET_CTRL_GRP("DB_zala421_HUD_alt_mainText", 956, 956)
	GET_CTRL_GRP("DB_zala421_HUD_coord_mainText", 825, 825)
	GET_CTRL_GRP("DB_zala421_HUD_fuel_mainText", 987, 987)
	GET_CTRL_GRP("DB_zala421_HUD_status_mainText", 125, 125)
	GET_CTRL_GRP("DB_zala421_HUD_droneSpeed_mainText", 127, 127)
	GET_CTRL_GRP("DB_zala421_HUD_pitch_mainText", 121, 121)

	[DISP_CTRL 1488, [DISP_CTRL 1489, DISP_CTRL 1490]]
};

CFM_fnc_initZalaInterfaceGunner = {
	params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

	GET_CTRL("DB_zala421_squareX_HUD", 237)
	GET_CTRL("DB_zala421_squareY_HUD", 825)
	GET_CTRL("DB_zala421_laser_HUD", 836)
	GET_CTRL("DB_zala421_height_HUD", 241)
	GET_CTRL("DB_zala421_speed_HUD", 369)
	GET_CTRL("DB_zala421_direction_HUD", 398)
	GET_CTRL("DB_zala421_temperature_HUD", 375)
	GET_CTRL("DB_zala421_date_HUD", 203)
	GET_CTRL("DB_zala421_time_HUD", 265)

	[DISP_CTRL 1488, [DISP_CTRL 1489, DISP_CTRL 1490]]
};

CFM_fnc_zala_drawHudDriver = {
	params[["_monitor", objNull], ["_uav", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

	private _positionATL = getPosATLVisual _uav;

	// ALT
	private _altMainText = uiNameSpace getVariable ["DB_zala421_HUD_alt_mainText" + _uiDisplayUniqueName, controlNull];
	_altMainText ctrlSetText format ["%1: %2", localize "STR_zala421_altitude", floor(_uav call CBA_fnc_realHeight)];

	// COORDINATES
	private _coordMainText = uiNameSpace getVariable ["DB_zala421_HUD_coord_mainText" + _uiDisplayUniqueName, controlNull];
	_coordMainText ctrlSetText format ["%1: %2 %3", localize "STR_zala421_square", floor((_positionATL # 0) / 100), floor((_positionATL # 1) / 100)];

	// FUEL
	private _fuelMainText = uiNameSpace getVariable ["DB_zala421_HUD_fuel_mainText" + _uiDisplayUniqueName, controlNull];
	_fuelMainText ctrlSetText format ["%1: %2", localize "STR_zala421_fuel", floor (fuel _uav * 100)];

	// STATUS
	private _statusMainText = uiNameSpace getVariable ["DB_zala421_HUD_status_mainText" + _uiDisplayUniqueName, controlNull];
	_statusMainText ctrlSetText format ["%1: %2", localize "STR_zala421_condition", [localize "STR_zala421_controllable", localize "STR_zala421_damaged"] select (damage _uav >= 0.33)];


	// DRONE SPEED
	private _droneSpeedMainText = uiNameSpace getVariable ["DB_zala421_HUD_droneSpeed_mainText" + _uiDisplayUniqueName, controlNull];
	_droneSpeedMainText ctrlSetText format ["%1: %2 KM/H", localize "STR_zala421_speed", (floor speed _uav)];

	// PITCH
	private _pitchMainText = uiNameSpace getVariable ["DB_zala421_HUD_pitch_mainText" + _uiDisplayUniqueName, controlNull];
	_pitchMainText ctrlSetText format ["%1: %2 °", localize "STR_zala421_pitch", floor((_uav call BIS_fnc_getPitchBank) # 0)];
};

CFM_fnc_zala_drawHudGunner = {
	params[["_monitor", objNull], ["_uav", objNull], ["_signal", 1], ["_uiCtrlCurrentUIDisplay", displayNull], ["_uiDisplayUniqueName", ""]];

	private _positionATL = getPosATLVisual _uav;

	// SQUARE X
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_squareX_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_squareX", floor((_positionATL # 0) / 100)];

	// SQUARE Y
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_squareY_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_squareY", floor((_positionATL # 1) / 100)];

	// LASER
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_laser_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_laser", [localize "STR_zala421_off", localize "STR_zala421_on"] select (isLaserOn _uav)];

	// HEIGHT
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_height_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_altitude", floor(_uav call CBA_fnc_realHeight)];

	// SPEED
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_speed_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_speed", floor(speed _uav)];

	// DIRECTION
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_direction_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;
	private _direction = getDirVisual _uav;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2</t>", localize "STR_zala421_course", floor _direction];

	// TEMPERATURE
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_temperature_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;

	_text ctrlSetStructuredText parseText format ["%1: <t align='right'>%2°C</t>", localize "STR_zala421_t", floor(ambientTemperature # 0)];

	// DATE
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_date_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;
	private _date = date;

	_text ctrlSetText format ["%1/%2/%3", _date # 2, _date # 1, _date # 0];

	// TIME
	private _controlsGroup = uiNameSpace getVariable ["DB_zala421_time_HUD" + _uiDisplayUniqueName, controlNull];
	private _text = _controlsGroup controlsGroupCtrl 101;
	private _time = [dayTime, "HH:MM:SS"] call BIS_fnc_timeToString;

	_text ctrlSetText _time;
};



// TEMP REB RECOMPILE
REB_fnc_disconectDrone = {
	if ((("lancet_tripod_launcher" in (typeOf vehicle player)) && dialog)) exitWith {
		closeDialog 1;
	};

	if !(_this getVariable ["REB_uavLostSignal", false]) then {
		_this setVariable ["REB_uavLostSignal", true, true];
	};

	player connectTerminalToUAV objNull; //disconnect from players terminal
	_noise ppEffectEnable false; //disable noise
	//delete drone ai crew so drone will fall, otherwise ai will try to hover on 
	_this remoteExec ["deleteVehicleCrew", 0];
	_this spawn {
		uiSleep REB_createUavCrewOnDisconectTime;
		_this remoteExec ["createVehicleCrew", 0];
		_this setVariable ["REB_uavLostSignal", false, true];
	};
};

REB_fnc_main = {
	params [["_freq", REB_freq], ["_random", REB_random], ["_noise", REB_noise], ["_uav", (vehicle (remoteControlled player))]];
	if (isNil {
		REB_isSuppressed = false;
		_noise ppEffectEnable false; 
		call REB_fnc_removeInputDelay;

		if !(missionNamespace getVariable ["REB_systemIsOn", true]) exitWith {};
		if (_uav getVariable ["REB_var_skipThis", false]) exitWith {};

		if (_uav getVariable ['ArmaFPV_EnableTI', false]) then {
			_uav disableTIEquipment false;
		};

		if (count REB_all_rebs == 0) exitWith {};

		private _isLancet = (("lancet_tripod_launcher" in (typeOf vehicle player)) && dialog);

		if !((_uav in allUnitsUAV) || _isLancet) exitWith {};

		if (_isLancet) then {
			_uav = uiNamespace getVariable ["lancet_currentProjectile", objNull];
		};

		if (_uav call REB_fnc_isInDeadzone) exitWith {
			_uav call REB_fnc_disconectDrone;
			false
		};

		private _activeRebStrength = _uav call REB_fnc_currentJammingRebStrength;

		if !(_activeRebStrength > 0) exitWith {};

		_uav disableTIEquipment true;

		if (_isLancet) then {
			false setCamUseTI 0;
		};

		_activeRebStrength call REB_fnc_suppress;
		if !(_uav getVariable ["REB_uavIsSuppressed", false]) then {
			_uav setVariable ["REB_uavIsSuppressed", true, true];
			_uav setVariable ["REB_uavActiveRebStrength", _activeRebStrength, true];
		};
		true
	}) then {
		if ((_uav getVariable ["REB_uavIsSuppressed", false]) && {(cameraOn isEqualTo _uav)}) then {
			_uav setVariable ["REB_uavIsSuppressed", false, true];
			_uav setVariable ["REB_uavActiveRebStrength", nil, true];
		};
	} else {

	};
};