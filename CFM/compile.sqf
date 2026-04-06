#include "defines.hpp"

CFM_fnc_init = {
	CFM_updateEachFrame = true;

	if (CFM_updateEachFrame) then {
		[] call CFM_fnc_setupDraw3dEH;
	};

	[] call CFM_fnc_initActionConditions;

	CFM_max_zoom_gopro = 2;
	CFM_max_zoom_drone = 5;

	["CFM_PIPsettings",  "EDITBOX",  ["PIP Settings", "PIP size and position settings: [size (number or [sizeX, sizeY]), posX, posY]"], "CFM Settings", DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;

	["CFM", "CFM_exitFullScreenKey", ["Exit Fullscreen Mode", "Exit Fullscreen Mode"], {call CFM_fnc_exitFullScreen}, "", [18, [true, false, false]]] call CBA_fnc_addKeybind;

	#include "Classes\DbHandler.sqf"
	#include "Classes\Monitor.sqf"
	#include "Classes\Operator.sqf"
	#include "Classes\CameraManager.sqf"

	NEW_INSTANCE("DbHandler");
	NEW_INSTANCE("CameraManager");

	CFM_inited = true;
};

CFM_fnc_updateOperator = {
	private _isRemoteControlling = isRemoteControlling player;
	if !(_isRemoteControlling) exitWith {};

	private _controlledObj = remoteControlled player;
	if !(local _controlledObj) exitWith {};
	if (_controlledObj isEqualTo objNull) exitWith {};
	if (_controlledObj isEqualTo player) exitWith {};
	if (_controlledObj isEqualTo (vehicle player)) exitWith {};

	// ZOOM
	private _currentFOV = getObjectFOV _controlledObj;
	private _currentZoom = round (1 / _currentFOV);
	private _prevZoom = _controlledObj getVariable ["CFM_prevZoom", _currentZoom];
	if (_currentZoom isEqualTo _prevZoom) then {
		_controlledObj setVariable ["CFM_prevZoom", _currentZoom, MONITOR_VIEWERS(false)];
	};

	// LOCAL TURRET ORIENTATION
	if (_controlledObj getVariable ["CFM_doCheckTurretLocality", false]) then {
		private _turretIndex = -1;
		if (_controlledObj isEqualTo (gunner (vehicle _controlledObj))) then {
			_turretIndex = 0;
		};
		private _monitorsSet = _controlledObj getVariable ["CFM_monitorsSet", createHashMap];
		private _monitors = _monitorsSet getOrDefault [_turretIndex, []];
		private _monitor = _monitors#0;

		if (isNil "_monitor") exitWith {};
		if !(IS_OBJ(_monitor)) exitWith {};

		private _prevTimeSet = missionNamespace getVariable ["CFM_prevTimeSetLocalCamVector", 0];
		private _cooldown = (diag_tickTime - _prevTimeSet) < SET_LOCAL_CAM_VECTORS_TIMEOUT;
		if !(_cooldown) then {
			private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
			private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
			private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {[NULL_VECTOR, [NULL_VECTOR, NULL_VECTOR]]}];
			private _posVDUp = [objNull, [_controlledObj, [_turretIndex], true, nil, nil, _monitor], _camPosFunc] call CFM_fnc_updateCamera;
			_posVDUp params [["_pos", NULL_VECTOR], ["_vdup", []]];
			_vdup params [["_dir", NULL_VECTOR], ["_up", NULL_VECTOR]];
			private _prevDir = _operator getVariable [_dirVarName, []];
			private _prevUp = _operator getVariable [_upVarName, []];
			private _currDirMS = _operator vectorWorldToModelVisual _dir;
			private _currUpMS = _operator vectorWorldToModelVisual _up;
			if !(_currDirMS isEqualTo _prevDir) then {
				_operator setVariable [_dirVarName, _currDirMS, MONITOR_VIEWERS(false)];
			};
			if !(_currUpMS isEqualTo _prevUp) then {
				_operator setVariable [_upVarName, _currUpMS, MONITOR_VIEWERS(false)];
			};
			missionNamespace setVariable ["CFM_prevTimeSetLocalCamVector", diag_tickTime];
		};
	};
};

CFM_fnc_onEachFrameClient = {
	if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};

	private _monitors = missionNamespace getVariable ["CFM_ActiveMonitors", []];
	{
		private _monitor = _x;
		private _condition = [_monitor, true] call CFM_fnc_monitorFeedActive;
		if (_condition) then {
			[_monitor] call CFM_fnc_updateMonitor;
		} else {	
			[_monitor] call CFM_fnc_stopOperatorFeed;
		};
	} forEach _monitors;

	if !(isMultiplayer) exitWith {};

	[] call CFM_fnc_updateOperator;
};

CFM_fnc_onEachFrameServer = {
	if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};

	if (missionNamespace getVariable ["CFM_makeCamDataSync", false]) then {
		{
			private _operator = _x;
			// CAM DATA
			private _turrets = _operator getVariable ["CFM_turrets", [[-1]]];
			{
				private _turretIndex = _x#0;
				private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
				private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
				private _currDir = _operator getVariable [_dirVarName, []];
				private _currUp = _operator getVariable [_upVarName, []];
				_operator setVariable [_dirVarName, _currDir, MONITOR_VIEWERS(false)];
				_operator setVariable [_upVarName, _currUp, MONITOR_VIEWERS(false)];
			} forEach _turrets;
			// ZOOM
			private _currentZoom = _operator getVariable ["CFM_prevZoom", 1];
			_operator setVariable ["CFM_prevZoom", _currentZoom, MONITOR_VIEWERS(false)];
		} forEach (missionNamespace getVariable ["CFM_Operators", []]);

		missionNamespace setVariable ["CFM_makeCamDataSync", false];
	};
};

CFM_fnc_setupDraw3dEH = {
	if (isNil "CFM_UPD_CLIENT_EH_id") then {
		CFM_UPD_CLIENT_EH_id = addMissionEventHandler ["EachFrame", {call CFM_fnc_onEachFrameClient}];
	};
	if (isNil "CFM_UPD_SERVER_EH_id") then {
		if (isServer && isMultiplayer) then {
			CFM_UPD_SERVER_EH_id = addMissionEventHandler ["EachFrame", {call CFM_fnc_onEachFrameServer}];
		};
	};
};

CFM_fnc_zoom = {
	params [["_monitor", 0], ["_zoomAdd", 0], ["_zoomSet", -1]]; 

	["zoom", [_zoomAdd, _zoomSet]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_setMonitor = {
	params[["_monitor", objNull], ["_params", []], ["_reset", false]];

	if (_monitor isEqualType []) exitWith {
		{
			[_x, _params, _reset] call CFM_fnc_setMonitor;
		} forEach _monitor;
	};
	if !(IS_OBJ(_monitor)) exitWith {};

	if (count _params == 0) then {
		_params = [[]];
	};
	_params pushBack _reset;

	[_monitor, _params] NEW_OBJINSTANCE("Monitor");
};

CFM_fnc_setOperator = {
	params["_operator", ["_reset", true], ["_type", ""], ["_hasTInNvg", [0, 0]], ["_params", []]];
	if (!_reset && {(IS_OBJ(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {false};
	["setOperator", [_operator, _type, _hasTInNvg, _params]] CALL_CLASS("DbHandler");
	true
};

CFM_fnc_operatorCondition = {
	params["_op", ["_player", player], ["_checkFeeding", false]];
	
	private _playerSide = side _player;
	private _side = side _op;
	private _sidesUseCiv = missionNamespace getVariable ["CFM_sidesCanUseCiv", []];
	if !(IS_OBJ(_op)) then {
		["removeOperator", [_monitor]] CALL_CLASS("DbHandler");
		continue
	};
	if (!(_side isEqualTo _playerSide) && {!((_playerSide in _sidesUseCiv) && {_side == civilian})}) exitWith {false};

	private _type = [_op] call CFM_fnc_cameraType;

	if (_checkFeeding && {!(_op getVariable ["CFM_isFeeding", false])}) exitWith {false};

	switch (_type) do {
		case GOPRO: {
			private _hasGoPro = _op getVariable ["CFM_hasGoPro", false];
			private _goprohelms = missionNamespace getVariable ["CFM_goProHelmets", createHashMap];
			if (_goprohelms isEqualTo createHashMap) exitWith {_hasGoPro};
			private _playerHelm = headgear _op;
			_playerHelm in _goprohelms;
		};
		case DRONETYPE: {
			private _cls = typeOf _op;
			if !(alive _op) exitWith {false};
			private _canFeed = _op getVariable ["CFM_canFeed", false];
			if (_canFeed) exitWith {true};
			private _clssSetup = missionNamespace getVariable ["CFM_OperatorClasses", []];
			if (_cls in _clssSetup) exitWith {
				[_op, false] call CFM_fnc_setOperator;
				true
			};
			_canFeed
		};
		default {false};
	};
};

CFM_fnc_getActiveOperatorsCheckGlobal = {
	private _objs = [];
	if (missionNamespace getVariable ["CFM_checkGoPros", false]) then {
		_objs append allUnits;
	}; 
	if (missionNamespace getVariable ["CFM_checkUavsCams", false]) then {
		_objs append allUnitsUAV;
	}; 
	if (missionNamespace getVariable ["CFM_checkVehCams", false]) then {
		_objs append vehicles;
	}; 
	_objs select {
		([_x] call CFM_fnc_operatorCondition)  
	}  
}; 

CFM_fnc_getActiveOperators = {
	(missionNamespace getVariable ["CFM_Operators", []]) select {[_x] call CFM_fnc_operatorCondition};
};

CFM_fnc_timeInterpolate = {
    params ["_obj", "_targetPos", "_targetDir", "_targetUp", ["_doInterpolate", true], ["_tightness", 5], ["_dt", diag_deltaTime]];
    
	if (!DO_CAM_INTERPOLATION) exitWith {
	// if (!DO_CAM_INTERPOLATION && !_doInterpolate) exitWith {
		[_targetPos, [_targetDir, _targetUp]];
	};

    // Формула затухания, независимая от FPS: 
    // Эффект = 1 - e^(-tightness * dt)
    private _interpFactor = 1 - (exp (-_tightness * _dt));

    // 1. Позиция
    private _lastPos = _obj getVariable ["CFM_cam_lastPos", _targetPos];
    private _newPos = +_lastPos;
    // Интерполируем каждую ось (или через vectorAdd/vectorDiff)
	for "_i" from 0 to 2 do {
        private _diff = (_targetPos select _i) - (_lastPos select _i);
        _newPos set [_i, (_lastPos select _i) + (_diff * _interpFactor)];
    };

    // 2. Векторы (Dir и Up)
    private _lastDir = _obj getVariable ["CFM_cam_lastDir", _targetDir];
    private _lastUp = _obj getVariable ["CFM_cam_lastUp", _targetUp];

    // Плавный поворот векторов
    private _newDir = _lastDir vectorAdd ((_targetDir vectorDiff _lastDir) vectorMultiply _interpFactor);
    private _newUp = _lastUp vectorAdd ((_targetUp vectorDiff _lastUp) vectorMultiply _interpFactor);

    // 3. Сохраняем состояние
    _obj setVariable ["CFM_cam_lastPos", _newPos];
    _obj setVariable ["CFM_cam_lastDir", _newDir];
    _obj setVariable ["CFM_cam_lastUp", _newUp];

    [_newPos, [_newDir, _newUp]];
};

CFM_fnc_updateCamera = {  
	params [["_cam", objNull], ["_cameraParams", []], ["_camPosFunc", CFM_fnc_camPosDroneDynamic]]; 
	_cameraParams params [
		["_operator", objNull],
		["_turret", [-1]],
		["_turretLocal", false],
		["_zoom", 1], 
		["_zoomTable", createHashMap],
		["_monitor", objNull]
	];
	private _doInterpolation = false;
	private _turretIndex = _turret#0;
	private _camExists = IS_OBJ(_cam);

	// ZOOM
	private _fov = if (_camExists) then {
		if (_zoom isEqualTo "op") then {
			_zoom = _operator getVariable ['CFM_prevZoom', _zoom];
		};
		private _zoomDefault = !(_zoom isEqualType 1);
		if !(_zoomDefault) then {
			private _zoomfov = _zoomTable getOrDefault [_zoom, 1/_zoom];
			if (_zoomfov > 1) then {getObjectFOV _operator} else {_zoomfov};
		} else {getObjectFOV _operator};
	} else {1};

	// POS AN VECTOR DIR AND UP
	private _operatorLocal = local _operator;

	private _pos = [];
	private _dir = [];
	private _up = [];
	if (_operatorLocal || !_turretLocal) then {
		private _posData = [_operator, _turretIndex] call _camPosFunc;
		_pos = _posData#0;
		_dir = _posData#1;
		_up = _posData#2;
	};

	if (_turretLocal && {isMultiplayer && {!_operatorLocal}}) then {
		_doInterpolation = true;
		private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
		private _localDirMS = _operator getVariable [_dirVarName, []];
		private _localUpMS = _operator getVariable [_upVarName, []];
		if (count _localDirMS == 3) then {
			_dir = _operator vectorModelToWorldVisual _localDirMS;
		};
		if (count _localUpMS == 3) then {
			_up = _operator vectorModelToWorldVisual _localUpMS;
		};
	};

	if ((count _pos) != 3) then {
		_pos = getPosASL _operator;
	};
	if ((count _dir) != 3) then {
		_dir = vectorDir _operator;
	};
	if ((count _up) != 3) then {
		_up = vectorUp _operator;
	};
	private _posAndVUP = [_monitor, _pos, _dir, _up, _doInterpolation] call CFM_fnc_timeInterpolate;
	_posAndVUP params ["_newpos", ["_vDirUp", []]];
	if (_camExists) then {
		_cam setPosASL _newpos; 
		_cam setVectorDirAndUp _vDirUp;  
		_cam camSetFov _fov;  
		_cam camCommit 0;  
	};

	_posAndVUP
};

CFM_fnc_camPosDroneDynamic = {
	params["_obj", "_curTurretIndex"];

	private _prevTurret = (+(_obj getVariable ["CFM_prevTurret", [_curTurretIndex]]))#0;
	private _pos = [];
	private _dir = [];
	private _up = [];
	if (([_curTurretIndex] isEqualTo DRIVER_TURRET_PATH) && {[_obj] call CFM_fnc_isPilotControlled}) then {
		_pos = _obj modelToWorldVisualWorld (getPilotCameraPosition _obj);
		private _camDir = _obj vectorModelToWorldVisual (getPilotCameraDirection _obj);
		private _camDirPos = ((vectorNormalized _camDir) vectorMultiply 1) vectorAdd _pos;
		private _fromToVUP = [_pos, _camDirPos] call BIS_fnc_findLookAt;
		_dir = _fromToVUP#0;
		_up = _fromToVUP#1;
	} else {
		private _dirPointParams = _obj getVariable ["CFM_camDirPointParams", []];  
		private _dirPoint = _obj getVariable ["CFM_camDirPoint", ""];  

		if (((_dirPoint isEqualTo "") || {(_dirPointParams isEqualTo []) || {(_dirPointParams isEqualTo "")}}) || !(_prevTurret isEqualTo _curTurretIndex)) then {
			private _pointsParams = [_obj, [_curTurretIndex]] call CFM_fnc_getUAVCameraPoints;
			_dirPointParams = _pointsParams#1; 
			_dirPoint = _dirPointParams;
			if (_dirPoint isEqualType []) then {_dirPoint = _dirPoint#0};
			_obj setVariable ["CFM_camDirPointParams", _dirPointParams];
			_obj setVariable ["CFM_camDirPoint", _dirPoint];
		};

		private _lod = OBJ_LOD(_obj);
		private _dirPointPos = selectionPosition [_obj, _dirPoint, _lod, true];
		private _dirPointVUP = _obj selectionVectorDirAndUp [_dirPoint, "Memory"];

		_pos = _obj modelToWorldVisualWorld _dirPointPos;
		_dir = _obj vectorModelToWorldVisual (_dirPointVUP#0);
		_up = _obj vectorModelToWorldVisual (_dirPointVUP#1);
	};

	[_pos, _dir, _up]
};

CFM_fnc_camPosDroneStatic = {
	params["_obj", "_curTurretIndex"];

	private _dir = vectorDir _obj;
	private _up = vectorUp _obj;
	private _offsetMS = _obj getVariable ["CFM_staticCamOffset", [0,0,0]];
	private _pos = _obj modelToWorldVisualWorld _offsetMS;

	[_pos, _dir, _up]
};

CFM_fnc_camPosGoPro = {
	params["_obj"];
	private _headPos = selectionPosition [_obj, "head", 9, true];
	private _dirUp = _obj selectionVectorDirAndUp ["head", "memory"]; 
	private _dir = _obj vectorModelToWorldVisual _dirUp#0;
	private _up = _obj vectorModelToWorldVisual _dirUp#1;
	private _headPos = [_obj, ["head", "memory"], [-0.19, 0.1, 0.25]] call CFM_fnc_getOffsetInModelSpace;
	private _pos = _obj modelToWorldVisualWorld _headPos; 

	_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];
		
	[_pos, _dir, _up]
};

CFM_fnc_defineCamTypeParams = {
	params["_operator", ["_type", ""]];

	private _cls = toLower (typeOf _operator);
	switch (_type) do {
		case GOPRO: {
			[CFM_fnc_camPosGoPro, CFM_max_zoom_gopro, CFM_goPro_zoomTable, [], false]
		};
		case DRONETYPE: {
			private _maxzoom = CFM_max_zoom_drone;
			private _table = CFM_drone_zoomTable;
			private _func = CFM_fnc_camPosDroneDynamic;
			private _offset = NULL_VECTOR;
			private _doCheckTurretLocality = true;
			if (("fpv" in _cls) || {("crocus" in _cls)}) then {
				_func = CFM_fnc_camPosDroneStatic;
				_offset = [0,0.1,0.15];
				_doCheckTurretLocality = false;
			} else {};
			[_func, _maxzoom, _table, _offset, _doCheckTurretLocality]
		};
		default {[]};
	};
};

CFM_fnc_updateMonitor = {
	params["_monitor"];

	private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _turret = _monitor getVariable ["CFM_currentTurret", [-1]];
	private _zoomMax = _monitor getVariable ["CFM_zoomMax", 1];
	private _zoom = _monitor getVariable ["CFM_zoom", 1];
	private _zoomTable = _monitor getVariable ["CFM_zoomTable", createHashMap];
	private _turLocal = _monitor getVariable ["CFM_turretLocal", false];
	private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {}];
	private _zoom = if (_zoom isEqualType 1) then {_zoom min _zoomMax} else {_zoom};
	private _camSet = [_camera, [_operator, _turret, _turLocal, _zoom, _zoomTable, _monitor], _camPosFunc] call CFM_fnc_updateCamera;

	private _updatePip = _monitor getVariable ["CFM_doUpdatePip", false];

	if (_updatePip) then {
		private _feedActive = _monitor getVariable ["CFM_feedActive", false];
		if !(_feedActive) exitWith {};
		private _currPip = _monitor getVariable ["CFM_currentPiPEffect", 0];
		[_monitor, _currPip] call CFM_fnc_setMonitorPiPEffect;
		_monitor setVariable ["CFM_doUpdatePip", false];
	};

	_camSet
};

CFM_fnc_getUAVCameraPoints = {  
    params ["_vehicle", ["_turretPath", DRIVER_TURRET_PATH]]; 

    private _droneType = toLower (typeOf _vehicle);

	if ("mavik" in _droneType) exitWith {
		[["pos_pilotcamera", [], [-1,0,-1]], "pos_pilotcamera_dir"]
	};
	if ("uav_01" in _droneType) exitWith {
		if (_turretPath isEqualTo DRIVER_TURRET_PATH) exitWith {
			[["pip_pilot_pos", [], [-1,0,-1]], "pip_pilot_dir"]
		};
		[["pip0_pos", [], [-1,0,-1]], "pip0_dir"]
	};

    private _camPos = "uavCameraGunnerPos";  
    private _camDir = "uavCameraGunnerDir";

    if (_turretPath isEqualTo [-1]) then {  
        if ("mavik" in _droneType) exitWith {};
        _camPos = "uavCameraDriverPos";  
        _camDir = "uavCameraDriverDir";  
    };

    private _config = configFile >> "CfgVehicles" >> typeOf _vehicle;  
    private _posPoint = getText (_config >> _camPos);  
    private _dirPoint = getText (_config >> _camDir);  
    if (_posPoint == "") then {  
        {  
            private _testPos = _vehicle selectionPosition _x;  
            if (!(_testPos isEqualTo [0,0,0])) exitWith {_posPoint = _x;};  
        } forEach ["PiP0_pos", "PiP1_pos", "pip0_pos", "pip1_pos", "pip_pilot_pos"];  
    };  
    if (_dirPoint == "") then {  
        {  
            private _testDir = _vehicle selectionPosition _x;  
            if (!(_testDir isEqualTo [0,0,0])) exitWith {_dirPoint = _x;};  
        } forEach ["PiP0_dir", "PiP1_dir", "pip0_dir", "pip1_dir", "flir", "pip_pilot_dir"];  
    };  
    [_posPoint, _dirPoint]  
};  

CFM_fnc_memoryPointAlignment = {
	params["_obj", ["_pointParams", "", [[], ""]]];

	private _lod = OBJ_LOD(_obj);

	if (_pointParams isEqualType "") exitWith {
		_s = selectionPosition [_obj, _pointParams, _lod, false];
		hintSilent str [_obj, "", _s, _lod, _pointParams];
		_s
	};
	if !(_pointParams isEqualType []) exitWith {
		[0,0,0]
	};

	_pointParams params [["_point", "", [""]], ["_addArr", [0,0,0], [[]]], ["_setArr", [-1,-1,-1], [[]]]];

	if ((count _addArr) != 3) then {
		_addArr = [0,0,0];
	};
	if ((count _setArr) != 3) then {
		_setArr = [-1,-1,-1];
	};

	private _selPos = selectionPosition [_obj, _point, _lod, true];
	_selPos = _selPos vectorAdd _addArr;

	for "_i" from 0 to 2 do {
		private _set = _setArr#_i;
		if (_set isEqualTo -1) then {continue};
		_selPos set [_i, _set];
	};
	_selPos
};

CFM_fnc_getOffsetInModelSpace = {
    params ["_unit", ["_selectionName", "head"], ["_offset", [0,0,0]]];

    // 1. Получаем позицию селекшна в Model Space
    private _selectionPosMS = _unit selectionPosition _selectionName;

    // 2. Получаем ориентацию селекшна (векторы направления и верха)
    private _dirUp = _unit selectionVectorDirAndUp _selectionName;
    private _dir = _dirUp#0;
    private _up = _dirUp#1;

    // 3. Строим правую сторону (вектор Right) для полной системы координат
    private _right = _dir vectorCrossProduct _up;

    // 4. Трансформируем офсет
    // Мы умножаем компоненты офсета на соответствующие векторы ориентации
    private _rotatedOffset = [0,0,0];
    _rotatedOffset = _rotatedOffset vectorAdd (_right vectorMultiply (_offset select 0)); // X - влево/вправо
    _rotatedOffset = _rotatedOffset vectorAdd (_dir   vectorMultiply (_offset select 1)); // Y - вперед/назад
    _rotatedOffset = _rotatedOffset vectorAdd (_up    vectorMultiply (_offset select 2)); // Z - вверх/вниз

    // 5. Итоговая позиция в Model Space
    _selectionPosMS vectorAdd _rotatedOffset
};

CFM_fnc_isPilotControlled = {
	params ["_veh", ["_by", objNull]];
	private _crew = crew _veh;
	if (_crew isEqualTo []) exitWith {false};
	private _driver = _crew#0;
	if (_driver isEqualTo objNull) exitWith {false};
	private _remoteControlledDriver = remoteControlled _driver;
	if (IS_OBJ(_by)) exitWith {(_remoteControlledDriver isEqualTo _by)};
	!(_remoteControlledDriver isEqualTo objNull)
};

CFM_fnc_monitorFeedActive = {
	params["_monitor"];

	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _cam = _monitor getVariable ["CFM_currentFeedCam", objNull]; 

	CHECK_EX(!IS_OBJ(_operator));
	CHECK_EX(!IS_OBJ(_cam));

	private _opType = _operator getVariable ["CFM_cameraType", GOPRO];

	CHECK_EX(!(_opType isEqualTo GOPRO) && {!(alive _operator)});
	
	private _active = _monitor getVariable ["CFM_feedActive", false]; 

	CHECK_EX(!_active);

	private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (_isHandMonitor && {!([_monitor] call CFM_fnc_hasUAVterminal)}) exitWith {false};

	true
};

CFM_fnc_doCheckTurretLocality = {
	params["_operator"];

	if !(IS_OBJ(_operator)) exitWith {false};

	[_operator] call CFM_fnc_isUAV;
};

CFM_fnc_createCamera = {
	"camera" camCreate [0,0,0];
};

CFM_fnc_destroyCamera = {
	params["_cam"];
	["destroyCamera", [_cam]] CALL_CLASS("CameraManager");
};

CFM_fnc_setupNvgAndTI = {
	params["_operator"];

	private _d = 0;
	private _typeOp = typeOf _operator;
	private _canSwitchTi = _operator getVariable ["CFM_canSwitchTi", 0];
	private _canSwitchNvg = _operator getVariable ["CFM_canSwitchNvg", 0];
	private _tiTable = _operator getVariable ["CFM_tiTable", []];
	private _nvgTable = _operator getVariable ["CFM_nvgTable", []];
	if (!(_canSwitchTi isEqualTo false) && ((_tiTable isEqualTo []) && {!(_tiTable isEqualTo createHashMap)})) then {
		private _tiPilot = getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "thermalMode");
		private _tiTurret = getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "thermalMode");
		
		private _tiModesTable = missionNamespace getVariable ["CFM_tiModesTable", createHashMap];

		_tiPilot = _tiPilot apply {
			_tiModesTable getOrDefault [_x, 2]
		};
		_tiTurret = _tiTurret apply {
			_tiModesTable getOrDefault [_x, 2]
		};

		_d = 1;

		_tiTable = if ((_tiPilot isEqualTo []) && {(_tiTurret isEqualTo [])}) then {
			createHashMap
		} else {
			_canSwitchTi = true;
			createHashMapFromArray [[-1, _tiPilot], [0, _tiTurret]];
		};
		_operator setVariable ["CFM_tiTable", _tiTable];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi];
	};
	if (!(_canSwitchNvg isEqualTo false) && (_nvgTable isEqualTo []) && {!(_nvgTable isEqualTo createHashMap)}) then {
		private _nvgPilot = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "visionMode"));
		private _nvgTurret = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "visionMode"));
		
		_d = _d + 2;

		_nvgTable = if (!_nvgPilot && !_nvgTurret) then {
			createHashMap
		} else {
			_canSwitchNvg = true;
			createHashMapFromArray [[-1, _nvgPilot], [0, _nvgTurret]];
		};
		_operator setVariable ["CFM_nvgTable", _nvgTable];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg];
	};

	if !(_canSwitchTi isEqualType true) then {
		_canSwitchTi = _canSwitchTi isEqualTo 1;
	};
	if !(_canSwitchNvg isEqualType true) then {
		_canSwitchNvg = _canSwitchNvg isEqualTo 1;
	};

	[_tiTable, _nvgTable, _canSwitchTi, _canSwitchNvg];
};

CFM_fnc_createPIPwindow = {
    params [["_player", objNull], ["_renderTarget", "rendertarget0"]];
    
    disableSerialization;
    
    [_player] call CFM_fnc_closePIPwindow;
    sleep 0.01;

    _renderTarget cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
    waitUntil {!(isNil {uiNamespace getVariable "RscTitleDisplayEmpty"})};
    private _display = uiNamespace getVariable "RscTitleDisplayEmpty";
    
    _player setVariable ["CFM_currentRscLayer", _renderTarget];
    _player setVariable ["CFM_currentDisplay", _display];
    
    private _settings = missionNamespace getVariable ["CFM_PIPsettings", DEFAULT_PIP_SETTINGS_STR]; 
	_settings = call compile _settings; 
	if ((isNil "_settings") || {!(_settings isEqualType [])}) then {
		_settings = DEFAULT_PIP_SETTINGS;
	};
    _settings params [["_size", 0.2], ["_offsetX", 1], ["_offsetY", 0.8]];

	private _w = _size;
	private _h = _size;
	if (_size isEqualType []) then {
		_w = _size#0;
		_h = _size#1;
	};

    private _totalW = _w * safeZoneW;
    private _totalH = _h * safeZoneH;
    
    private _bgX = safeZoneX + (safeZoneW - _totalW) * _offsetX;
    private _bgY = safeZoneY + (safeZoneH - _totalH) * _offsetY;

    private _borderSize = 0.004;
    private _headerHeight = 0.03; 

    private _background = _display ctrlCreate ["RscText", -1];
    _background ctrlSetBackgroundColor [0, 0, 0, 1];
    _background ctrlSetPosition [_bgX, _bgY, _totalW, _totalH];
    _background ctrlCommit 0;

    private _title = _display ctrlCreate ["RscText", -1];
    _title ctrlSetText "CAMERA FEED";
    _title ctrlSetTextColor [1, 1, 1, 1]; 
    _title ctrlSetPosition [
        _bgX, 
        _bgY, 
        _totalW, 
        _headerHeight
    ];
    _title ctrlSetScale 0.85; 
    _title ctrlCommit 0;

    private _pictureCtrl = _display ctrlCreate ["RscPicture", -1];
    
    private _picX = _bgX + _borderSize;
    private _picY = _bgY + _headerHeight;
    private _picW = _totalW - (_borderSize * 2);
    private _picH = _totalH - _headerHeight - _borderSize;

    _pictureCtrl ctrlSetPosition [_picX, _picY, _picW, _picH];
    _pictureCtrl ctrlSetText (format ["#(argb,512,512,1)r2t(%1,1.0)", _renderTarget]);
    _pictureCtrl ctrlCommit 0;
    
    _player setVariable ["CFM_currentPictureCtrl", _pictureCtrl];

    [_display, _pictureCtrl, _background, _title]
};

CFM_fnc_closePIPwindow = {
	params[["_player", player]];
	private _renderTarget = _player getVariable ["CFM_currentRscLayer", ""];
	_renderTarget cutFadeOut 0;
    private _prevDisplay = _player getVariable ["CFM_currentDisplay", displayNull];
    if (!isNull _prevDisplay) then { _prevDisplay closeDisplay 1; };
};

CFM_fnc_setHandDisplay = {
	params[["_player", player], ["_render", true]];

	private _renderTarget = _player getVariable ["CFM_currentR2T", ""];

	if (_render && {IS_VALID_R2T(_renderTarget)}) then {
		[_player, _renderTarget] spawn CFM_fnc_createPIPwindow;
	} else {
		[_player] call CFM_fnc_closePIPwindow;
	};
};

CFM_fnc_setMonitorTexture = {
	params["_monitor", ["_render", true], ["_r2t", ""], ["_turnOff", false]];

	["setRenderPicture", [_render, _r2t, _turnOff]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_getNextRenderTarget = {
	private _index = ["nextR2Tindex"] CALL_CLASS("DbHandler");
	RENDER_TARGET_STR + str _index;
};

CFM_fnc_setMonitorPiPEffect = {
	params["_monitor", ["_pipEffect", 0]];
	if !(_pipEffect isEqualType 0) exitWith {false};
	private _renderTarget = _monitor getVariable ["CFM_currentR2T", "rendertarget0"];  
	_renderTarget setPiPEffect [_pipEffect];
	_monitor setVariable ["CFM_currentPiPEffect", _pipEffect]; 
	true
};

CFM_fnc_monitorSwitchTi = {
	params["_monitor"];
	["switchTi"] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_enterMonitorFullScreen = {
	params["_monitor"];
	["monitorEnterFullScreen", [_monitor]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_exitMonitorFullScreen = {
	params["_monitor"];
	["monitorExitFullScreen", [_monitor]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_exitFullScreen = {
	LOGH [time];
	if !(missionNamespace getVariable ["CFM_isInFullScreen", false]) exitWith {};
	hint "";
	cutText ["", "PLAIN"];
	private _currCam = missionNamespace getVariable ["CFM_currentFullScreenCam", objNull];
	if !(IS_OBJ(_currCam)) exitWith {
		private _currCamData = (allCameras select {(_x#3) isEqualTo "Internal"})#0;
		if (isNil "_currCamData") exitWith {
			LOGH "ERROR CFM_fnc_exitFullScreen: cant find current Internal camera!";
		};
		_currCam = _currCamData#0;
		_currCam cameraEffect ["Terminate", "back"];
		player switchCamera "INTERNAL";
	};
	private _r2t = missionNamespace getVariable ["CFM_r2tOfFullScreenCam", ""];
	missionNamespace setVariable ["CFM_currentFullScreenCam", nil];
	missionNamespace setVariable ["CFM_r2tOfFullScreenCam", nil];
	missionNamespace setVariable ["CFM_isInFullScreen", false];
	if !(IS_VALID_R2T(_r2t)) exitWith {
		_currCam cameraEffect ["Terminate", "back"];
		player switchCamera "INTERNAL";
	};
	_currCam cameraEffect ["Internal", "back", _r2t];
	player switchCamera "INTERNAL";
};

CFM_fnc_resetFeed = {
	params["_monitor", ["_turret", DRIVER_TURRET_PATH]];
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _currTurret = _monitor getVariable ["CFM_currentTurret", _turret];  
	[_monitor, true] call CFM_fnc_stopOperatorFeed;
	if !(IS_OBJ(_operator)) exitWith {};
	private _hndl = _monitor getVariable ["CFM_monitorMainHndl", scriptNull];
	if !(_hndl isEqualType scriptNull) then {
		_hndl = scriptNull;
	};
	waitUntil {scriptDone (_hndl)};
	[_monitor, _operator, _currTurret, true] call CFM_fnc_startOperatorFeed;
};

CFM_fnc_connectMonitorToOperator = {  
	params ["_monitor", "_operator", ["_caller", objNull]];  
	["connect", [_operator, _caller], _monitor, 0] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_disconnectMonitorFromOperator = {  
	params ["_monitor", ["_caller", objNull]];  
	["disconnect", [_caller]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_startOperatorFeed = {  
	params ["_monitor", "_operator", ["_turret", DRIVER_TURRET_PATH], ["_reset", false]];  
	["startFeed", [_operator, _turret, _reset], _monitor] CALL_OBJCLASS("Monitor", _monitor);
}; 

CFM_fnc_stopOperatorFeed = {  
	params ["_monitor", ["_reset", false]];  
	["stopFeed", [_reset], _monitor] CALL_OBJCLASS("Monitor", _monitor);
}; 

CFM_fnc_syncState = { 
	params ["_mNetId", "_oNetId", ["_start", true], ["_turret", DRIVER_TURRET_PATH]]; 

	private _monitor = objectFromNetId _mNetId; 
	private _operator = objectFromNetId _oNetId; 

	private _isWaiting = _monitor getVariable ["CFM_waitingForStart", false]; 

	if (_isWaiting && _start) exitWith {};

	_monitor setVariable ["CFM_waitingForStart", _start];

	if (_start) then {
		waitUntil {
			private _dist = _monitor distance player;
			private _isClose = _dist <= START_MONITOR_FEED_DIST;
			_start = _monitor getVariable ["CFM_waitingForStart", true];
			if (_isClose) exitWith {true};
			if !(_start) exitWith {true};
			sleep 1;
			_isClose
		};
	};
	if (_start) then { 
		if (_monitor getVariable ["CFM_feedActive", false]) exitWith {}; 
		[_monitor, _operator] call CFM_fnc_startOperatorFeed; 
	} else {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	}; 
	_monitor setVariable ["CFM_waitingForStart", false]; 
}; 

CFM_fnc_remoteExec = {
	params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", 0], ["_call", false, [false]]];


	if (_targets isEqualType true) then {
		if (_targets isEqualTo true) then {
			_targets = 0;
		} else {
			_targets = false;
		};
	};
	if (_jip isEqualType objNull) then {
		private _netid = netId _jip;
		private _idArr = (_netid splitString ":");
		private _id = "0";
		if (count _idArr > 1) then {
			_id = _idArr#1;
			if !(_id isEqualType "") then {
				_id = str _id;
			};
		};
		_jip = "CFM_jip_remote_exec_id_" + _id;
	};

	if ((_targets isEqualTo player) || {(_targets isEqualTo false) || {(_targets isEqualTo (clientOwner))}}) exitWith {
		if (_func isEqualTo "call") exitWith {
			(_args#0) call (_args#1)
		};
		if (_func isEqualTo "spawn") exitWith {
			(_args#0) spawn (_args#1)
		};
		private _func = missionNamespace getVariable [_func, {LOGH format["CFM_fnc_remoteExec ERROR: func '%1' not found!", _func]}];
		if (_call) then {
			_args call _func
		} else {
			_args spawn _func
		};
	};

	_args remoteExec [_func, _targets, _jip];
};

CFM_fnc_fixFeed = {
	private _monitors = missionNamespace getVariable ["CFM_Monitors", []];
	{
		[_x] spawn CFM_fnc_resetFeed;
	} forEach _monitors;
};

CFM_fnc_cameraType = {
	params["_obj"];

	if !(IS_OBJ(_obj)) exitWith {""};

	private _type = _obj getVariable ["CFM_cameraType", ""];

	if !(IS_STR(_type)) then {
		_type = "";
	};

	if !(_type isEqualTo "") exitWith {_type};

	private _cls = typeOf _obj;
	private _classType = [_cls] call CFM_fnc_validClassType;

	if ((_obj isKindOf "Man") || {_classType isEqualTo TYPE_UNIT}) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_HELM) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_UAV) exitWith {
		DRONETYPE
	};
	DRONETYPE
};

CFM_fnc_validClassType = {
	params["_cls"];

	private _isVeh = isClass (configFile >> "CfgVehicles" >> _cls);
	if (_isVeh && {(getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav")) isEqualTo 1}) exitWith {TYPE_UAV};
	if (_isVeh && {_cls isKindOf "Man"}) exitWith {TYPE_UNIT};
	if (_isVeh) exitWith {TYPE_VEH};
	private _isWeap = isClass (configFile >> "CfgWeapons" >> _cls);
	if (_isWeap && {
		private _parents = [configFile >> "CfgWeapons" >> _cls >> "ItemInfo", true] call BIS_fnc_returnParents;
		"headgearItem" in _parents
	}) exitWith {TYPE_HELM};
	if (_isWeap) exitWith {TYPE_WEAP};

	""
};

CFM_fnc_hasUAVterminal = {
	params["_player"];

	'terminal' in (toLower (_player getSlotItemName 612))
};

CFM_fnc_isUAV = {
	params["_obj"];

	(_obj isKindOf "Air") && {(getNumber (configFile >> "CfgVehicles" >> (typeOf _obj) >> "isUav")) isEqualTo 1}
};

CFM_fnc_initActionConditions = {
	#define HAND_MON_CONDITION if ([_target] call CFM_fnc_handMonitorMenuActionCondition) exitWith {false};
	CFM_fnc_handMonitorMenuActionCondition = {
		params["_target"];

		private _isHandMonitor = _target getVariable ["CFM_isHandMonitor", false];
		if !(_isHandMonitor) exitWith {false};

		private _isWatchingAtMonitor = isNil {cursorObject getVariable "CFM_originalTexture"};
		
		!_isWatchingAtMonitor
	};
	CFM_fnc_menuActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		if (_target getVariable ['CFM_feedActive', false]) exitWith {false};
		if (_target getVariable ['CFM_menuActive', false]) exitWith {false};
		private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
		_target call _additionalCondition
	};
	CFM_fnc_menuCloseActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_menuActive', false])
	};
	CFM_fnc_disconnectActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		_target getVariable ['CFM_feedActive', false]
	};
	CFM_fnc_connectActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_menuActive', false])
	};
	CFM_fnc_zoomInActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && !(_target getVariable ['CFM_maxZoomed', false])
	};
	CFM_fnc_zoomActionsCondition = {
		params["_target"];
		HAND_MON_CONDITION
		_target getVariable ['CFM_feedActive', false]
	};
	CFM_fnc_connectDroneActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOperatorIsDrone', false]) &&
			{[player] call CFM_fnc_hasUAVterminal}
		}
	};
	CFM_fnc_fixFeedActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false])
	};
	CFM_fnc_switchCameraToGunnerActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOpHasTurrets', false]) && {
				((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [-1])
			}
		}
	};
	CFM_fnc_switchCameraToPilotActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOpHasTurrets', false]) && {
				((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [0])
			}
		}
	};
	CFM_fnc_turnOffActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {!(_target getVariable ['CFM_turnedOffLocal', false])}
	};
	CFM_fnc_turnOnActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {(_target getVariable ['CFM_turnedOffLocal', false])}
	};
	CFM_fnc_toggleNvgActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_monitorCanSwitchNvg', false]) && {
				!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#0) && {
					(
						(_target getVariable ['CFM_currentNvgTable', createHashMap]) getOrDefault 
						[((_target getVariable ['CFM_currentTurret', [-1]])#0), false]
					)
				}
			}
		}
	};
	CFM_fnc_toggleTiActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_monitorCanSwitchTi', false]) && {
				!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#1) && {
					(
						!(
							(
								(_target getVariable ['CFM_currentTiTable', createHashMap]) getOrDefault 
								[((_target getVariable ['CFM_currentTurret', [-1]])#0), []]
							) isEqualTo []
						)
					)
				}
			}
		}
	};
	CFM_fnc_enterFullScreenActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		if !(_target getVariable ['CFM_feedActive', false]) exitWith {false};
		if !(_target getVariable ['CFM_canFullScreen', false]) exitWith {false};
		private _connectedOperator = _target getVariable ['CFM_connectedOperator', objNull];
		if (_connectedOperator getVariable ['CFM_hasGoPro', false]) exitWith {false};
		focusOn == player
	};
	CFM_fnc_exitFullScreenActionCondition = {
		params["_target"];
		focusOn != player
	};
};