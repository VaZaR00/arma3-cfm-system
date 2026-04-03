#include "defines.hpp"

CFM_fnc_init = {
	CFM_updatePosSystem = true;

	if (CFM_updatePosSystem) then {
		[] call CFM_fnc_setupDraw3dEH;
	};

	CFM_max_zoom_gopro = 2;
	CFM_max_zoom_drone = 5;

	["CFM_PIPsettings",  "EDITBOX",  ["PIP Settings", "PIP size and position settings: [size (number or [sizeX, sizeY]), posX, posY]"], "CFM Settings", DEFAULT_PIP_SETTINGS_STR] call CBA_fnc_addSetting;

	#include "Classes\DbHandler.sqf"
	#include "Classes\Monitor.sqf"
	#include "Classes\Operator.sqf"
	#include "Classes\CameraManager.sqf"

	NEW_INSTANCE("DbHandler");
	NEW_INSTANCE("CameraManager");

	CFM_inited = true;
};

CFM_fnc_updateOperatorZoom = {
	private _isRemoteControlling = isRemoteControlling player;
	if !(_isRemoteControlling) exitWith {};

	private _controlledObj = remoteControlled player;
	if (_controlledObj isEqualTo objNull) exitWith {};
	if (_controlledObj isEqualTo player) exitWith {};
	if (_controlledObj isEqualTo (vehicle player)) exitWith {};

	private _currentFOV = getObjectFOV _controlledObj;
	private _currentZoom = round (1 / _currentFOV);
	private _prevZoom = _controlledObj getVariable ["CFM_prevZoom", _currentZoom];

	if (_currentZoom isEqualTo _prevZoom) exitWith {};

	_controlledObj setVariable ["CFM_prevZoom", _currentZoom, true];
};

CFM_fnc_draw3dEH = {
	if !(missionNamespace getVariable ["CFM_updatePosSystem", false]) exitWith {};

	private _operators = missionNamespace getVariable ["CFM_ActiveOperators", []];
	{
		private _condition = [_x, true] call CFM_fnc_operatorCondition;
		if (_condition) then {
			[_x] call CFM_fnc_updateOperator;
		} else {	
			["removeActiveOperator", [_x]] CALL_CLASS("DbHandler");
		};
	} forEach _operators;

	// UPDATE OBJECT ZOOM
	[] call CFM_fnc_updateOperatorZoom;
};

CFM_fnc_setupDraw3dEH = {
	if !(isNil "CFM_EH_id") exitWith {};
	private _id = addMissionEventHandler ["Draw3D", {call CFM_fnc_draw3dEH}];
	CFM_EH_id = _id;
};

CFM_fnc_zoom = {
	params [["_monitor", 0], ["_zoomAdd", 0], ["_zoomSet", -1]]; 

	["zoom", [_zoomAdd, _zoomSet]] CALL_OBJCLASS(_monitor);
};

CFM_fnc_setMonitor = {
	params[["_monitor", objNull], ["_params", []]];

	if (_monitor isEqualType []) exitWith {
		{
			[_x, _params] call CFM_fnc_setMonitor;
		} forEach _monitor;
	};
	if !(IS_OBJ(_monitor)) exitWith {};

	[_monitor, _params] NEW_OBJINSTANCE("Monitor");
};

CFM_fnc_setOperator = {
	params["_operator", ["_reset", true], ["_type", ""], ["_hasTInNvg", [0, 0]], ["_params", []]];
	if (!_reset && {(IS_OBJ(_operator)) && {((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true)}}) exitWith {};
	["setOperator", [_operator, _type, _hasTInNvg, _params]] CALL_CLASS("DbHandler");
};

CFM_fnc_cameraCondition = {
	true
};

CFM_fnc_operatorCondition = {
	params["_op", ["_checkFeeding", false]];
	
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
	private _playerSide = side player;
	_objs select {  
		private _side = side _x;
		private _sidesUseCiv = missionNamespace getVariable ["CFM_sidesCanUseCiv", []];
		((_side isEqualTo _playerSide) || ((_playerSide in _sidesUseCiv) && {_side == civilian})) && 
		(_x call CFM_fnc_operatorCondition)  
	}  
}; 

CFM_fnc_getActiveOperators = {
	(missionNamespace getVariable ["CFM_Operators", []]) select {_x call CFM_fnc_operatorCondition};
};

CFM_fnc_timeInterpolate = {
    params ["_cam", "_targetPos", "_targetDir", "_targetUp", ["_doInterpolate", true], ["_tightness", 5], ["_dt", diag_deltaTime]];
    
	if (!DO_CAM_INTERPOLATION && !_doInterpolate) exitWith {
		[_targetPos, [_targetDir, _targetUp]];
	};

    // Формула затухания, независимая от FPS: 
    // Эффект = 1 - e^(-tightness * dt)
    private _interpFactor = 1 - (exp (-_tightness * _dt));

    // 1. Позиция
    private _lastPos = _cam getVariable ["CFM_cam_lastPos", _targetPos];
    private _newPos = +_lastPos;

    // Интерполируем каждую ось (или через vectorAdd/vectorDiff)
    for "_i" from 0 to 2 do {
        private _diff = (_targetPos select _i) - (_lastPos select _i);
        _newPos set [_i, (_lastPos select _i) + (_diff * _interpFactor)];
    };

    // 2. Векторы (Dir и Up)
    private _lastDir = _cam getVariable ["CFM_cam_lastDir", _targetDir];
    private _lastUp = _cam getVariable ["CFM_cam_lastUp", _targetUp];

    // Плавный поворот векторов
    private _newDir = _lastDir vectorAdd ((_targetDir vectorDiff _lastDir) vectorMultiply _interpFactor);
    private _newUp = _lastUp vectorAdd ((_targetUp vectorDiff _lastUp) vectorMultiply _interpFactor);

    // 3. Сохраняем состояние
    _cam setVariable ["CFM_cam_lastPos", _newPos];
    _cam setVariable ["CFM_cam_lastDir", _newDir];
    _cam setVariable ["CFM_cam_lastUp", _newUp];

    [_newPos, [_newDir, _newUp]];
};

CFM_fnc_updateCamera = {  
	params ["_cam", ["_cameraParams", []], ["_setup", false, [false]], ["_justZoom", false, [false]]]; 
	_cameraParams params [
		["_operator", objNull],
		["_turret", [-1]],
		["_zoom", 1], 
		["_turretLocal", false, [false]]
	];
	private _turretIndex = _turret#0;

	([_operator, _cam, _zoom, _turret, _justZoom] call CFM_fnc_getCamPos) params [["_pos", [0,0,0]], ["_dir", [0,0,0]], ["_up", [0,0,0]], ["_fov", 1]];
	

	if (_turretLocal) then {
		private _dirVarName = "CFM_currentTurretDir" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUp" + str _turretIndex;
		if ((local _operator) && {!([_operator] call CFM_fnc_isPilotControlled)}) then {
			private _prevDir = _operator getVariable [_dirVarName, []];
			private _prevUp = _operator getVariable [_upVarName, []];
			private _currDir = vectorDir _cam;
			private _currUp = vectorUp _cam;
			if !(_currDir isEqualTo _prevDir) then {
				_operator setVariable [_dirVarName, vectorDir _cam, true];
			};
			if !(_currUp isEqualTo _prevUp) then {
				_operator setVariable [_upVarName, vectorUp _cam, true];
			};
		} else {
			_doInterpolation = true;
			_setup = true;
			_pos = [];
			_dir = _operator getVariable [_dirVarName, []];
			_up = _operator getVariable [_upVarName, []];
		};
	};

	if (_setup) then {
		private _posAndVUP = [_cam, _pos, _dir, _up, _doInterpolation] call CFM_fnc_timeInterpolate;
		_posAndVUP params ["_newpos", ["_vDirUp", []]];
		_vDirUp params [["_newdir", []], ["_newup", []]];
		if ((count _newpos) == 3) then {
			_cam setPosASL _newpos; 
		};
		if (((count _newdir) == 3) && {((count _newup) == 3)}) then {
			_cam setVectorDirAndUp [_newdir, _newup];  
		};
	};
	_cam camSetFov _fov;  
	_cam camCommit 0;  
};

CFM_fnc_updateOperator = {
	params["_operator"];

	private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
	{
		private _turret = [_x];
		private _cameras = _y;
		{
			private _camera = _x#1;
			private _camParams = _x#2;
			[_camera, _camParams, true, false] call CFM_fnc_updateCamera;
		} forEach _cameras;
	} forEach _camerasSet;
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
	params ["_veh"];
	private _crew = crew _veh;
	if (_crew isEqualTo []) exitWith {false};
	private _driver = _crew#0;
	if (_driver isEqualTo objNull) exitWith {false};
	private _remoteControlledDriver = remoteControlled _driver;
	!(_remoteControlledDriver isEqualTo objNull)
};

CFM_fnc_getCamPos = {
	params["_obj", "_cam", ["_zoom", 1], ["_turretPath", DRIVER_TURRET_PATH, [[]], 1], ["_justZoom", false]];

	private _prevTurret = 0;
	private _curTurret = 0;
	if !(_justZoom) then {
		_prevTurret = (+(_obj getVariable ["CFM_prevTurret", +_turretPath]))#0;
		_curTurret = _turretPath#0;
		_obj setVariable ["CFM_prevTurret", +_turretPath];
	};

	private _type = _obj getVariable ["CFM_cameraType", GOPRO];

	if (_zoom isEqualTo "op") then {
		_zoom = _operator getVariable ['CFM_prevZoom', _zoom];
	};

	private _zoomDefault = !(_zoom isEqualType 1);

	switch (_type) do {
		case GOPRO: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				private _headPos = selectionPosition [_obj, "head", 9, true];
				private _dirUp = _obj selectionVectorDirAndUp ["head", "memory"]; 
				_dir = _obj vectorModelToWorldVisual _dirUp#0;
				_up = _obj vectorModelToWorldVisual _dirUp#1;
				_headPos = [_obj, ["head", "memory"], [-0.19, 0.1, 0.25]] call CFM_fnc_getOffsetInModelSpace;
				_pos = _obj modelToWorldVisualWorld _headPos; 

				_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];
			};

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_gopro", 2]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > DEF_FOV_GOPRO) then {DEF_FOV_GOPRO} else {_zoomfov};
			} else {DEF_FOV_GOPRO};
			[_pos, _dir, _up, _fov]
		};
		case DRONETYPE: {
			private _pos = [];
			private _dir = [];
			private _up = [];
			if !(_justZoom) then {
				if ((_turretPath isEqualTo DRIVER_TURRET_PATH) && {[_obj] call CFM_fnc_isPilotControlled}) then {
					_pos = _obj modelToWorldVisualWorld (getPilotCameraPosition _obj);
					private _camDir = _obj vectorModelToWorldVisual (getPilotCameraDirection _obj);
					private _camDirPos = ((vectorNormalized _camDir) vectorMultiply 1) vectorAdd _pos;
					private _fromToVUP = [_pos, _camDirPos] call BIS_fnc_findLookAt;
					_dir = _fromToVUP#0;
					_up = _fromToVUP#1;
				} else {
					private _dirPointParams = _obj getVariable ["CFM_camDirPointParams", []];  
					private _dirPoint = _obj getVariable ["CFM_camDirPoint", ""];  

					if (((_dirPoint isEqualTo "") || {(_dirPointParams isEqualTo []) || {(_dirPointParams isEqualTo "")}}) || !(_prevTurret isEqualTo _curTurret)) then {
						private _pointsParams = [_obj, _turretPath] call CFM_fnc_getUAVCameraPoints;
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
			};

			private _fov = if !(_zoomDefault) then {
				_zoom = _zoom min (missionNamespace getVariable ["CFM_max_zoom_drone", 5]);
				private _zoomfov = [_zoom, _type] call CFM_fnc_getZoomFov;
				if (_zoomfov > 1) then {getObjectFOV _obj} else {_zoomfov};
			} else {getObjectFOV _obj};

			[_pos, _dir, _up, _fov]
		};
		default {[]};
	};
};

CFM_fnc_getZoomFov = {
	params["_zoom", ["_type", GOPRO]];

	private _table = missionNamespace getVariable [(switch (_type) do {
		case GOPRO: {
			"CFM_goPro_zoomTable"
		};
		case DRONETYPE: {
			"CFM_drone_zoomTable"
		};
		default {"CFM_nullvar"};
	}), createHashMap];

	if !(_table isEqualType createHashMap) exitWith {1};

	_table getOrDefault [_zoom, 1/_zoom];
};

CFM_fnc_monitorLiveCondition = {
	params["_monitor"];

	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _cam = _monitor getVariable ["CFM_operatorCam", objNull]; 

	CHECK_EX(!IS_OBJ(_operator));
	CHECK_EX(!IS_OBJ(_cam));

	private _opType = _operator getVariable ["CFM_cameraType", GOPRO];

	CHECK_EX(!(_opType isEqualTo GOPRO) && !(alive _operator));
	CHECK_EX(!(alive _cam));
	
	private _active = _monitor getVariable ["CFM_feedActive", false]; 

	CHECK_EX(!_active);

	private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (_isHandMonitor && {!([_monitor] call CFM_fnc_hasUAVterminal)}) exitWith {false};

	true
};

CFM_fnc_monitorFeedActive = {
	params["_monitor"];

	private _active = _monitor getVariable ["CFM_feedActive", false]; 

	_active
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

CFM_fnc_attachCam = {
	params["_monitor", "_obj", "_cam", ["_turretPath", DRIVER_TURRET_PATH, [[]], 1]];

	[_monitor, true] call CFM_fnc_updateCamera;

	private _turPathNum = str (_turretPath#0);
	private _relPos = _obj getVariable [("CFM_relPos_" + (_turPathNum)), 0];
	private _memPoint = _obj getVariable [("CFM_memPoint_" + (_turPathNum)), 0];
	private _orient = _obj getVariable [("CFM_orient_" + (_turPathNum)), 0];
	if ((_relPos isEqualTo 0) || {(_memPoint isEqualTo 0) || {(_orient isEqualTo 0)}}) then {
		_relPos = _obj worldToModel (getPos _cam);
		_memPoint = _obj getVariable ["CFM_camPosPoint", ""];
		_orient = [_cam, _obj] call (missionNamespace getVariable ["BIS_fnc_vectorDirAndUpRelative", {[[0,0,0], [0,0,0]]}]);

		if (_memPoint isEqualTo GOPRO_MEMPOINT) then {
			private _headRelPos = _obj selectionPosition [GOPRO_MEMPOINT, "Memory"];
			_relPos = _relPos vectorDiff _headRelPos;
			_relPos = _relPos vectorAdd [0,0,0.2];
		};

		_obj setVariable [("CFM_relPos_" + (_turPathNum)), _relPos];
		_obj setVariable [("CFM_memPoint_" + (_turPathNum)), _memPoint];
		_obj setVariable [("CFM_orient_" + (_turPathNum)), _orient];
	};

	_cam attachTo [_obj, _relPos, _memPoint, true];
	_cam setVectorDirAndUp _orient;
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

	private _renderTarget = _player getVariable ["CFM_renderTarget", ""];

	if (_render) then {
		[_player, _renderTarget] spawn CFM_fnc_createPIPwindow;
	} else {
		[_player] call CFM_fnc_closePIPwindow;
	};
};

CFM_fnc_setMonitorTexture = {
	params["_monitor", ["_render", true], ["_r2t", ""]];

	["setRenderPicture", [_render, _r2t]] CALL_OBJCLASS(_monitor);
};

CFM_fnc_getNextRenderTarget = {
	private _index = ["nextR2Tindex"] CALL_CLASS("DbHandler");
	RENDER_TARGET_STR + str _index;
};

CFM_fnc_setMonitorPiPEffect = {
	params["_monitor", ["_pipEffect", 0]];
	private _renderTarget = _monitor getVariable ["CFM_renderTarget", "rendertarget0"];  
	_renderTarget setPiPEffect [_pipEffect];
	_monitor setVariable ["CFM_currentPiPEffect", _pipEffect]; 
};

CFM_fnc_resetFeed = {
	params["_monitor"];
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];  
	private _turret = _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH];  
	[_monitor, true] call CFM_fnc_stopOperatorFeed;
	if (IS_OBJ(_operator)) exitWith {};
	private _hndl = _monitor getVariable ["CFM_monitorMainHndl", scriptNull];
	if !(_hndl isEqualType scriptNull) then {
		_hndl = scriptNull;
	};
	waitUntil {scriptDone (_hndl)};
	[_monitor] call CFM_fnc_startOperatorFeed;
};

CFM_fnc_connectOperatorToMonitor = {  
	params ["_monitor", "_operator"];  
	["connect", [_operator], _monitor] CALL_OBJCLASS(_monitor);
};

CFM_fnc_startOperatorFeed = {  
	params ["_monitor", "_operator"];  
	["startFeed", [_operator], _monitor] CALL_OBJCLASS(_monitor);
}; 

CFM_fnc_stopOperatorFeed = {  
	params ["_monitor", ["_reset", false]];  
	["stopFeed", [_reset], _monitor] CALL_OBJCLASS(_monitor);
}; 

CFM_fnc_syncState = { 
	params ["_mNetId", "_oNetId", ["_start", true], ["_turret", DRIVER_TURRET_PATH]]; 

	private _monitor = objectFromNetId _mNetId; 
	private _operator = objectFromNetId _oNetId; 

	private _cam = _monitor getVariable ["CFM_currentFeedCam", objNull];

	if (IS_OBJ(_cam)) exitWith {};

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
			_targets = 2;
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
	private _monitors = missionNamespace getVariable ["CFM_currentMonitors", []];
	{
		[_x] spawn CFM_fnc_resetFeed;
	} forEach _monitors;
};

CFM_fnc_objClassInstance = {
	params["_obj"];
	private _instance = GET_CLASS_INST(_obj);
	if !(IS_FUNC(_instance)) exitWith {{}};
	_instance
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