#include "defines.hpp"

CFM_fnc_updateOperator = {
	private _currVeh = vehicle PLAYER_;
	if !(_currVeh isEqualTo PLAYER_) then {
		[_currVeh] call CFM_fnc_updateOperatorZoom;
	};

	private _controlledUnit = focusOn;
	private _prevControlledUnit = PLAYER_ getVariable ["CFM_lastControlledUnit", objNull];
	if !(_prevControlledUnit isEqualTo _controlledUnit) then {
		// unit changed
		PLAYER_ setVariable ["CFM_lastControlledUnit", _controlledUnit];
		PLAYER_ setVariable ["CFM_lastControlledUnitTurretIndex", nil];
		PLAYER_ setVariable ["CFM_lastControlledUnitIsTurrLocal", nil];
		PLAYER_ setVariable ["CFM_lastControlledUnitMonitor", nil];
		// for remote controlled menu handling
		PLAYER_ setVariable ['CFM_menuActive', false];
	};
	
	if (isNull _controlledUnit) exitWith {};
	if (_controlledUnit isEqualTo PLAYER_) exitWith {};
	private _controlledObj = vehicle _controlledUnit;

	if !(local _controlledObj) exitWith {};

	private _turretIndex = PLAYER_ getVariable ["CFM_lastControlledUnitTurretIndex", -2];
	private _turrLocal = PLAYER_ getVariable ["CFM_lastControlledUnitIsTurrLocal", false];
	private _monitor = PLAYER_ getVariable ["CFM_lastControlledUnitMonitor", objNull];
	if (_turretIndex < -1) then {
		private _role = assignedVehicleRole _controlledUnit;
		if (_role isEqualTo []) exitWith {};
		_turretIndex = _role call CFM_fnc_getTurretIndex;
		private _turrsParams = _controlledObj getVariable "CFM_turretsParams";
		if (isNil "_turrsParams") exitWith {};
		if !(_turrsParams isEqualType createHashMap) exitWith {};
		private _currTurrParams = _turrsParams get _turretIndex;
		if (isNil "_currTurrParams") exitWith {};
		if !(_currTurrParams isEqualType createHashMap) exitWith {};
		_turrLocal = _currTurrParams getOrDefault ["IsTurretLocal", false];
		private _monitorsSet = _controlledObj getVariable ["CFM_monitorsSet", createHashMap];
		private _monitors = _monitorsSet getOrDefault [_turretIndex, []];
		_monitor = _monitors#0;
		PLAYER_ setVariable ["CFM_lastControlledUnitTurretIndex", _turretIndex];
		PLAYER_ setVariable ["CFM_lastControlledUnitIsTurrLocal", _turrLocal];
		PLAYER_ setVariable ["CFM_lastControlledUnitMonitor", _monitor];
	};

	if (isNil "_monitor") exitWith {};
	if !(IS_OBJ(_monitor)) exitWith {};

	// LOCAL TURRET ORIENTATION
	if (_turrLocal) then {
		private _prevTimeSet = missionNamespace getVariable ["CFM_prevTimeSetLocalCamVector", 0];
		private _cooldown = (diag_tickTime - _prevTimeSet) < SET_LOCAL_CAM_VECTORS_TIMEOUT;
		if !(_cooldown) then {
			private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
			private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
			private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {[NULL_VECTOR, [NULL_VECTOR, NULL_VECTOR]]}];
			private _pointParams = _monitor getVariable ["CFM_currentCamPointParams", []];
			private _turretObj = _monitor getVariable ["CFM_connectedTurretObject", objNull];
			private _posVDUp = [objNull, [_controlledObj, _turretObj, [_turretIndex], true, _pointParams, nil, _monitor, false, false, false, false], _camPosFunc] call CFM_fnc_updateCamera;
			_posVDUp params [["_pos", NULL_VECTOR], ["_vdup", []]];
			_vdup params [["_dir", NULL_VECTOR], ["_up", NULL_VECTOR]];
			private _prevDir = _controlledObj getVariable [_dirVarName, []];
			private _prevUp = _controlledObj getVariable [_upVarName, []];
			private _currDirMS = _controlledObj vectorWorldToModelVisual _dir;
			private _currUpMS = _controlledObj vectorWorldToModelVisual _up;
			if !(_currDirMS isEqualTo _prevDir) then {
				_controlledObj setVariable [_dirVarName, _currDirMS, MONITOR_VIEWERS_AND_SELF(false)];
			};
			if !(_currUpMS isEqualTo _prevUp) then {
				_controlledObj setVariable [_upVarName, _currUpMS, MONITOR_VIEWERS_AND_SELF(false)];
			};
			[_controlledObj] call CFM_fnc_updateOperatorZoom;
			missionNamespace setVariable ["CFM_prevTimeSetLocalCamVector", diag_tickTime];
		};
	};
};

CFM_fnc_updateOperatorZoom = {
	params["_obj"];
	private _currentFOV = getObjectFOV _obj;
	private _prevZoom = _obj getVariable ["CFM_prevZoomLocalFov", -1];
	if !(_currentFOV isEqualTo _prevZoom) then {
		_obj setVariable ["CFM_prevZoomLocalFov", _currentFOV, MONITOR_VIEWERS_AND_SELF(false)];
	};
	_currentFOV
};

CFM_fnc_onEachFrameClient = {
	if !(missionNamespace getVariable ["CFM_updateEachFrame", false]) exitWith {};

	private _monitors = missionNamespace getVariable ["CFM_ActiveMonitors", []];
	private _optimizeDistance = missionNamespace getVariable ["CFM_optimizeByDistance", OPTIMIZE_MONITOR_FEED_DIST];
	_optimizeDistance = call compile _optimizeDistance;
	private _doOptimize = _optimizeDistance > 0;
	{
		private _monitor = _x;
		private _condition = _monitor call CFM_fnc_monitorFeedActive;
		private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
		if (!(_isHandMonitor) && {_doOptimize}) then {
			private _dist = PLAYER_ distance _monitor;
			if (_dist > _optimizeDistance) then {
				private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
				[_monitor] call CFM_fnc_stopOperatorFeed;
				[_monitor, _operator, true] spawn CFM_fnc_syncState;
				continue;
			};
		};
		if (_condition) then {
			[_monitor] call CFM_fnc_updateMonitor;
		} else {	
			[_monitor] call CFM_fnc_stopOperatorFeed;
		};
	} forEach _monitors;
	
	// upd actions to remote controlled units
	private _plr = PLAYER_;	
	private _isHandMonitor = _plr getVariable ["CFM_isHandMonitor", false];
	if (_isHandMonitor) then {
		private _unit = focusOn;
		if !(_unit isEqualTo _plr) then {
			private _unitIsSet = _unit getVariable ["CFM_actionsSet", false];
			if (_unitIsSet) exitWith {};
			[_plr, _unit] call CFM_fnc_copyMenuActionsToObj;
		};
	};
};

CFM_fnc_serverLoop = {
	while {missionNamespace getVariable ["CFM_doServerLoop", true]} do {
		if (missionNamespace getVariable ["CFM_stopServerLoop", false]) then {continue};
		call CFM_fnc_checkupAllActiveOperators;
		uiSleep CHECK_OP_COND_FREQ;
	};
};

CFM_fnc_checkupAllActiveOperators = {
	{
		private _monitor = _x;
		private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
		if !(IS_OBJ(_operator)) then {continue};
		private _opCond = [_operator, _monitor] call CFM_fnc_operatorCondition;
		if !(_opCond) then {
			[_monitor, _monitor] call CFM_fnc_disconnectMonitorFromOperator;
		};
		_operator call CFM_fnc_checkOperatorTurrets;
	} forEach (missionNamespace getVariable ["CFM_Monitors", []]);
};

CFM_fnc_setupOpSyncVarEH = {
	"CFM_operatorsToUpdate" addPublicVariableEventHandler CFM_fnc_syncOperators;
};

CFM_fnc_syncOperators = {
	private _updOps = missionNamespace getVariable ["CFM_operatorsToUpdate", []];
	if !(_updOps isEqualType []) then {_updOps = [_updOps]};
	if (missionNamespace getVariable ["CFM_makeCamDataSync", false]) then {
		_updOps = _updOps + (missionNamespace getVariable ["CFM_Operators", []]);
		missionNamespace setVariable ["CFM_makeCamDataSync", false];
	};
	private _targets = MONITOR_VIEWERS_AND_SELF(false);
	{
		private _operator = _x;
		if !(IS_OBJ(_operator)) then {continue};
		// CAM DATA
		private _turrets = _operator getVariable ["CFM_turrets", [[-1]]];
		{
			private _turretIndex = TURRET_INDEX(_x);
			private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
			private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
			private _currDir = _operator getVariable [_dirVarName, []];
			private _currUp = _operator getVariable [_upVarName, []];
			_operator setVariable [_dirVarName, _currDir, _targets];
			_operator setVariable [_upVarName, _currUp, _targets];
		} forEach _turrets;
		// ZOOM
		private _currentZoom = _operator getVariable ["CFM_prevZoomLocalFov", 1];
		_operator setVariable ["CFM_prevZoomLocalFov", _currentZoom, _targets];
		// ACTIVE TURRETS
		private _hasActiveTurretsObjects = _operator getVariable ["CFM_hasActiveTurretsObjects", -1];
		_operator setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, _targets];
		private _activeTurretsObjects = _operator getVariable ["CFM_activeTurretsObjects", createHashMap];
		_operator setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, _targets];
		// TURRET PARAMS
		private _turretsParams = _operator getVariable ["CFM_turretsParams", createHashMap];
		_operator setVariable ["CFM_turretsParams", _turretsParams, _targets];
	} forEach _updOps;
	missionNamespace setVariable ["CFM_operatorsToUpdate", []];
	_updOps
};

CFM_fnc_setupDraw3dEH = {
	if (isNil "CFM_UPD_CLIENT_EH_id") then {
		if !(hasInterface) exitWith {};
		private _func = {call CFM_fnc_onEachFrameClient};
		if (true) then {
			_func = {call CFM_fnc_onEachFrameClient; call CFM_fnc_updateOperator};
		};
		CFM_UPD_CLIENT_EH_id = addMissionEventHandler ["EachFrame", _func];
	};
};

CFM_fnc_zoom = {
	params [["_monitor", 0], ["_zoomAdd", 0], ["_zoomSet", -1]]; 

	["zoom", [_zoomAdd, _zoomSet]] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_getFovForZoom = {
	params["_zoom"];
	
	if !(_zoom isEqualType 1) exitWith {1};

	1 / _zoom;
};

CFM_fnc_operatorCondition = {
	params["_op", ["_monitor", objNull], ["_checkFeeding", false]];

	if !(IS_OBJ(_monitor)) exitWith {false};

	private _hasActiveTurretsObjects = _op getVariable ["CFM_hasActiveTurretsObjects", -1];
	if (_hasActiveTurretsObjects isEqualTo 0) exitWith {false};

	if !(IS_VALID_OP(_op)) then {
		["removeOperator", [_op]] CALL_CLASS("DbHandler");
		continue
	};
	private _cls = _op call CFM_fnc_getOperatorClass;
	private _monitorSides = _monitor getVariable ["CFM_monitorSides", [side _monitor]];
	private _sidesOp = _op getVariable ["CFM_opSides", [[(getNumber (configFile >> "CfgVehicles" >> _cls >> "side"))] call BIS_fnc_sideType]];
	private _sidesUseCiv = missionNamespace getVariable ["CFM_sidesCanUseCiv", []];
	if !(_sidesOp isEqualType []) then {
		_sidesOp = [_sidesOp];
	};
	if !(_monitorSides isEqualType []) then {
		_monitorSides = [_monitorSides];
	};
	private _bySide = (_monitorSides findIf {_x in _sidesOp}) != -1;
	private _bySideCiv = (_monitorSides findIf {_x in _sidesUseCiv}) != -1;
	if (!_bySide && {!(_bySideCiv && {civilian in _sidesOp})}) exitWith {false};

	if (_checkFeeding && {!(_op getVariable ["CFM_isFeeding", false])}) exitWith {false};

	private _type = [_op] call CFM_fnc_cameraType;

	switch (_type) do {
		case GOPRO: {
			private _hasGoPro = _op getVariable ["CFM_hasGoPro", false];
			private _goprohelms = missionNamespace getVariable "CFM_goProHelmets";
			if (isNil "_goprohelms") exitWith {_hasGoPro};
			private _playerHelm = headgear _op;
			_playerHelm in _goprohelms;
		};
		case TYPE_STATIC: {
			true
		};
		default {
			if !(alive _op) exitWith {false};
			private _canFeed = _op getVariable ["CFM_canFeed", false];
			if (_canFeed) exitWith {true};
			private _clssSetup = missionNamespace getVariable ["CFM_OperatorClasses", []];
			if (_cls in _clssSetup) exitWith {
				private _reset = false;
				[_op] call CFM_fnc_setOperator;
				true
			};
			_canFeed
		};
	};
};

CFM_fnc_checkOperatorTurrets = {
	params["_operator"];

	private _hasActiveTurretsObjects = _operator getVariable ["CFM_hasActiveTurretsObjects", -1];

	if (_hasActiveTurretsObjects isEqualTo -1) exitWith {-1};

	private _activeTurretsObjects = _operator getVariable ["CFM_activeTurretsObjects", createHashMap];
	private _aliveTurret = 0;
	private ["_turretIndex", "_turretObj"];
	{
		_turretIndex = _x;
		_turretObj = _y;
		if (IS_OBJ(_turretObj) && {alive _turretObj}) then {
			_aliveTurret = _aliveTurret + 1;
		} else {
			[_operator, _turretIndex] call CFM_fnc_removeActiveTurret;
		};
	} forEach _activeTurretsObjects;
	_operator setVariable ["CFM_hasActiveTurretsObjects", _aliveTurret, MONITOR_VIEWERS_AND_SELF(false)];

	_aliveTurret
};

CFM_fnc_removeActiveTurret = {
	params[["_operator", objNull], ["_turretIndex", -1]];
	["removeActiveTurret", _turretIndex] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_addActiveTurret = {
	params[["_operator", objNull], ["_turretIndex", -1], ["_turretObject", objNull]];
	["addActiveTurret", [_turretIndex, _turretObject]] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_getActiveOperatorsCheckGlobal = {
	params[["_monitor", objNull]];
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
		([_x, _monitor] call CFM_fnc_operatorCondition)  
	}  
}; 

CFM_fnc_getActiveOperators = {
	params[["_monitor", objNull]];
	(missionNamespace getVariable ["CFM_Operators", []]) select {[_x, _monitor] call CFM_fnc_operatorCondition};
};

CFM_fnc_timeInterpolate = {
    params ["_prevValue", "_targetValue", ["_tightness", 0.01 max (parseNumber (MGVAR ["CFM_camInterpolation_tightness", "5"]))], ["_dt", diag_deltaTime]];
    
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
};

CFM_fnc_updateCamera = {  
	params [["_cam", objNull], ["_cameraParams", []], ["_camPosFunc", CFM_fnc_camPosVehTurret]]; 
	_cameraParams params [
		["_operator", objNull],
		["_turretObject", objNull],
		["_turret", [-1]],
		["_turretLocal", false],
		["_pointParams", []],
		["_zoomFov", 1], 
		["_monitor", objNull],
		["_doInterpolation", false],
		["_smoothZoom", true],
		["_doSetCam", true],
		["_setLocalOpTurretDir", true]
	];
	private _turretIndex = _turret#0;
	private _camExists = IS_OBJ(_cam);
	// private _operatorLocal = local _operator;

	// ZOOM
	private _fov = if ((_zoomFov isEqualType 1) && {(_zoomFov > 0) && (_zoomFov <= 1)}) then {
		_zoomFov
	} else {
		if (_zoomFov isEqualTo "op") exitWith {
			if !(isMultiplayer) exitWith {
				getObjectFov _operator
			};
			_operator getVariable ['CFM_prevZoomLocalFov', 1];
		};
		1
	};

	// POS AN VECTOR DIR AND UP
	private _posData = [_turretObject, _pointParams] call _camPosFunc;
	_posData params [
		["_pos", getPosASL _operator, [[]], 3], 
		["_dir", vectorDir _operator, [[]], 3], 
		["_up", vectorUp _operator, [[]], 3]
	];

	if (_turretLocal && {isMultiplayer && {_setLocalOpTurretDir}}) then {
		private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
		private _localDirMS = _operator getVariable [_dirVarName, []];
		private _localUpMS = _operator getVariable [_upVarName, []];
		if ((_localDirMS isEqualType []) && {(count _localDirMS == 3)}) then {
			_dir = _operator vectorModelToWorldVisual _localDirMS;
		};
		if ((_localUpMS isEqualType []) && {(count _localUpMS == 3)}) then {
			_up = _operator vectorModelToWorldVisual _localUpMS;
		};
	};

	private _newFov = _fov;
	private _newPos = _pos;
	private _newDir = _dir;
	private _newUp = _up;
	if (_doInterpolation) then {
		private _interpTightnessOffset = 0.01 max (parseNumber (MGVAR ["CFM_camInterpolation_tightnessOffset", "5"]));
		// private _lastPos = _monitor getVariable ["CFM_camInterp_lastPos", _pos];
		private _lastDir = _monitor getVariable ["CFM_camInterp_lastDir", _dir];
		private _lastUp = _monitor getVariable ["CFM_camInterp_lastUp", _up];
		// _newPos = [_lastPos, _pos, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
		_newDir = [_lastDir, _dir, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
		_newUp = [_lastUp, _up, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
		// _monitor setVariable ["CFM_camInterp_lastPos", _newPos];
		_monitor setVariable ["CFM_camInterp_lastDir", _newDir];
		_monitor setVariable ["CFM_camInterp_lastUp", _newUp];
	};
	if (_smoothZoom) then {
		private _interpTightnessZoom = 0.01 max (parseNumber (MGVAR ["CFM_camInterpolation_tightnessZoom", "10"]));
		private _lastFov = _monitor getVariable ["CFM_camInterp_lastFov", _fov];
		_newFov = [_lastFov, _fov, _interpTightnessZoom] call CFM_fnc_timeInterpolate;
		_monitor setVariable ["CFM_camInterp_lastFov", _newFov];
	};
	if (_camExists && _doSetCam) then {
		_cam setPosASL _newPos; 
		_cam setVectorDirAndUp [_newDir, _newUp];  
		_cam camSetFov _newFov;  
		_cam camCommit 0;  
	};

	[_newPos, [_newDir, _newUp]]
};

CFM_fnc_camPosVehTurret = {
	params["_obj", ["_pointParams", []]];

	_pointParams params [["_memPoint", ""], ["_alignment", []]];

	private _doAlign = !(_alignment isEqualTo []);
	private _dirPointPos = if (_doAlign) then {
		[_obj, _memPoint, _alignment] call CFM_fnc_memoryPointAlignment;
	} else {
		_obj selectionPosition [_memPoint, "Memory"]
	};
	private _dirPointVUP = _obj selectionVectorDirAndUp [_memPoint, "Memory"];

	private _pos = _obj modelToWorldVisualWorld _dirPointPos;
	private _dir = _obj vectorModelToWorldVisual (_dirPointVUP#0);
	private _up = _obj vectorModelToWorldVisual (_dirPointVUP#1);

	[_pos, _dir, _up]
};

CFM_fnc_camPosPilotTurret = {
	params[["_obj", objNull]];

	private _pos = _obj modelToWorldVisualWorld (getPilotCameraPosition _obj);
	private _camDir = _obj vectorModelToWorldVisual (getPilotCameraDirection _obj);
	private _camDirPos = ((vectorNormalized _camDir) vectorMultiply 1) vectorAdd _pos;
	private _fromToVUP = [_pos, _camDirPos] call BIS_fnc_findLookAt;
	private _dir = _fromToVUP#0;
	private _up = _fromToVUP#1;

	[_pos, _dir, _up]
};

CFM_fnc_camPosVehStatic = {
	params["_obj", ["_offsetMS", []]];

	if !(_offsetMS isEqualType []) then {
		_offsetMS = call CAM_POS_FUNC_DEF;
	};
	_offsetMS params [["_", ""], ["_offsets", []]];
	_offsets params [["_offsetPos", NULL_VECTOR], ["_vdup", [NULL_VECTOR, NULL_VECTOR]]];
	_vdup params [["_odir", NULL_VECTOR], ["_oup", NULL_VECTOR]];

	private _objDir = vectorDirVisual _obj;
	private _objUp = vectorUpVisual _obj;
	private _dirRel = _obj vectorWorldToModelVisual _objDir;
	private _upRel = _obj vectorWorldToModelVisual _objUp;
	_dirRel = _dirRel vectorAdd _odir;
	_upRel = _upRel vectorAdd _oup;
	private _dir = _obj vectorModelToWorldVisual _dirRel;
	private _up = _obj vectorModelToWorldVisual _upRel;
	private _pos = _obj modelToWorldVisualWorld _offsetPos;

	[_pos, _dir, _up]
};

CFM_fnc_camPosGoPro = {
	params["_obj"];
	private _headPos = selectionPosition [_obj, "head", 9, true];
	private _dirUp = _obj selectionVectorDirAndUp ["head", "memory"]; 
	private _dir = _obj vectorModelToWorldVisual _dirUp#0;
	private _up = _obj vectorModelToWorldVisual _dirUp#1;
	private _headPos = [_obj, ["head", "memory"], [-0.19, 0.1, 0.25]] call CFM_fnc_getMemPointOffsetInModelSpace;
	private _pos = _obj modelToWorldVisualWorld _headPos; 

	_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];
		
	[_pos, _dir, _up]
};

CFM_fnc_camPosStatic = {
	params["_obj", ["_offset", []]];
	// _offset params [["_pos", [0,0,0], [[]], 3], ["_vdirup", [], [[]], 2]];
	// _vdirup params [["_dir", [0,0,0], [[]], 3], ["_up", [0,0,0], [[]], 3]];

	// [_pos, _dir, _up]
	_offset
};

CFM_fnc_updateMonitor = {
	params["_monitor"];

	// upd cam pos
	private _isStatic = _monitor getVariable ["CFM_currentCameraIsStatic", false];
	private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
	private _zoomFov = _monitor getVariable ["CFM_zoomFov", 1];
	private _smoothZoom = _monitor getVariable ["CFM_currentCameraSmoothZoom", true];
	private _offsetReached = true;

	private _camSet = if (!_isStatic || 
	{
		(_smoothZoom && {
			// zoom interpolation
			private _currentFov = _monitor getVariable ["CFM_camInterp_lastFov", _zoomFov];
			if !(_currentFov isEqualType 1) exitWith {true};
			private _fovDiff = abs (_zoomFov - _currentFov);
			_fovDiff > DO_INTERPOLATE_TOLERANCE
		}) ||
		{
			// offset interpolation
			private _doUpdateCamera = _monitor getVariable ["CFM_doUpdateCamera", false];
			if (_doUpdateCamera isEqualType true) exitWith {_doUpdateCamera};
			if !(_doUpdateCamera isEqualType []) exitWith {false};
			private _currPos = getPosASL _camera;
			private _currDir = vectorDir _camera;
			private _currUp = vectorUp _camera;
			_doUpdateCamera params [["_pos", _currPos, [[]], 3], ["_dir", _currDir, [[]], 3], ["_up", _currUp, [[]], 3]];
			_offsetReached = (
				([_pos, _currPos] call CFM_fnc_compareVectors) && 
				{([_dir, _currDir] call CFM_fnc_compareVectors) && 
				{([_up, _currUp] call CFM_fnc_compareVectors)}}
			);
			if (_offsetReached) then {
				_monitor setVariable ["CFM_doUpdateCamera", false];
			};
			!_offsetReached
		}
	}
	) then {
		private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
		private _turretObj = _monitor getVariable ["CFM_connectedTurretObject", _operator];
		private _turret = _monitor getVariable ["CFM_currentTurret", [-1]];
		private _turLocal = _monitor getVariable ["CFM_turretLocal", false];
		private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {}];
		private _pointParams = _monitor getVariable ["CFM_currentCamPointParams", []];
		private _doInterpolation = _monitor getVariable ["CFM_camDoInterpolation", false];
		if (_offsetReached) then {
			_monitor setVariable ["CFM_doUpdateCamera", false];
		};
		[_camera, [_operator, _turretObj, _turret, _turLocal, _pointParams, _zoomFov, _monitor, _doInterpolation, _smoothZoom], _camPosFunc] call CFM_fnc_updateCamera;
	} else {false};

	// upd pip
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

CFM_fnc_getCameraPoints = {  
    params ["_vehicle", ["_turretPath", DRIVER_TURRET_PATH], ["_camType", ""]]; 

    private _vehType = toLower (typeOf _vehicle);
	_turretPath = TURRET_INDEX(_turretPath);

	if ("mavik" in _vehType) exitWith {
		[["pos_pilotcamera", [], [-1,0,-1]], "pos_pilotcamera_dir"]
	};
	if ("uav_01" in _vehType) exitWith {
		if (_turretPath in DRIVER_TURRET_PATH) exitWith {
			[["pip_pilot_pos", [], [-1,0,-1]], "pip_pilot_dir"]
		};
		[["pip0_pos", [], [-1,0,-1]], "pip0_dir"]
	};

	private _camTypeRes = switch (_camType) do {
		case TYPE_VEH: {
			// private _name = "gunnerview";
			// private _name = "zamerny";
			private _name = "konec hlavne";
			// private _name = "otocvez";
			if ((["bmp"] findIf {_x in _vehType}) != -1) then {
				_name = "mainturret";
			};
			private _dirParamsDef = [_name, [-0.3, 0.0, 0.2]];
			[_name, _dirParamsDef]
		};
		default { };
	};
	if !(isNil "_camTypeRes") exitWith {_camTypeRes};

    private _camPos = "uavCameraGunnerPos";  
    private _camDir = "uavCameraGunnerDir";

    if (_turretPath isEqualTo -1) then {  
        if ("mavik" in _vehType) exitWith {};
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
	params["_obj", ["_memPoint", ""], ["_pointParams", "", [[], ""]]];

	if (_pointParams isEqualType "") exitWith {
		_obj selectionPosition [_pointParams, "Memory"];
	};

	_pointParams params [["_addArr", [0,0,0], [[]], 3], ["_setArr", [-1,-1,-1], [[]], 3]];

	private _selPos = [_obj, [_memPoint, "Memory"], _addArr] call CFM_fnc_getMemPointOffsetInModelSpace;
 
	for "_i" from 0 to 2 do {
		private _set = _setArr#_i;
		if (_set isEqualTo -1) then {continue};
		_selPos set [_i, _set];
	};
	_selPos
};

CFM_fnc_setPointAlignment = {
	params[["_operator", objNull], ["_args", []]];
	["setPointAlignment", _args] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_initDefaultPointsAlignment = {
	private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
	
	private _vehConfigClasses = (("true" configClasses (configFile >> "CfgVehicles") apply {toLower (configName _x)}) select {_c = _x; (["Man", "Land", "Air"] findIf {_c isKindOf _x}) != -1});

	// default offset for vehs is [-0.3, 0.0, 0.2] in CFM_fnc_getCameraPoints
	private _defaults = [
		[["t72", "bmd2", "bmd1"], [[-1, [[-0.5,-0.8,0.3]]]]],
		[["bmp2"], [[-1, [[-0.8,0.3,0.2]]]]],
		[["bmp1"], [[-1, [[-0.3,0.45,0.7]]]]],
		[["t80", "t90"], [[-1, [[-0.5,-0.6,0.3]]]]],
		[["btr", "brdm"], [[-1, [[-0.2,0.1,0.1]]]]],
		[["m1a2"], [[-1, [[-0.8,-0.2,0.8]]]]],
		[["fpv", "crocus"], [[-1, [[0.0, 0.2, 0.1]]]]]
	];
	{
		private _checkClasses = false;
		private _cls = (_x#0);
		if (_cls isEqualType []) then {
			_checkClasses = true;
			_cls = _cls apply {toLower _x};
		} else {
			_cls = toLower _cls;
		};
		private _params = createHashMapFromArray (_x#1);
		if (_checkClasses) then {
			private _fitClasses = _vehConfigClasses select {private _c = _x; (_cls findIf {_x in _c}) != -1};
			{
				_pointSet set [_x, _params];
			} forEach _fitClasses;
		} else {
			_pointSet set [_cls, _params];
		};
	} forEach _defaults;

	missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSet];
	_pointSet
};

CFM_fnc_setDefaultPointAlignment = {
	params[["_operator", objNull]];
	["setDefaultPointAlignment", []] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_getMemPointOffsetInModelSpace = {
    params ["_obj", ["_selectionData", ["head", "Memory"]], ["_offset", [0,0,0]]];

	_selectionData params [["_selectionName", ""], ["_lod", "Memory"]];

    // 1. Получаем позицию селекшна в Model Space
    private _selectionPosMS = _obj selectionPosition [_selectionName, _lod];

    // 2. Получаем ориентацию селекшна (векторы направления и верха)
    private _dirUp = _obj selectionVectorDirAndUp _selectionData;
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
	private _monitor = _this;
	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _cam = _monitor getVariable ["CFM_currentFeedCam", objNull]; 

	CHECK_EX(!IS_OBJ(_operator));
	CHECK_EX(!IS_OBJ(_cam));

	private _opType = _operator getVariable ["CFM_cameraType", GOPRO];

	CHECK_EX(!(_opType isEqualTo GOPRO) && {_operator call CFM_fnc_goProCondition});
	
	private _active = _monitor getVariable ["CFM_feedActive", false]; 

	CHECK_EX(!_active);

	private _isHandMonitor = _monitor getVariable ["CFM_isHandMonitor", false];
	if (_isHandMonitor && {!(_monitor call CFM_fnc_handMonitorCondition)}) exitWith {false};

	true
};

CFM_fnc_handMonitorCondition = {
	private _monitorItem = missionNamespace getVariable "CFM_handMonitorItem";
	if (isNil "_monitorItem") exitWith {
		_this call CFM_fnc_hasUAVterminal
	};

	if !(_monitorItem isEqualType "") exitWith {false};

	[_this, _monitorItem] call BIS_fnc_hasItem;
};

CFM_fnc_goProCondition = {
	private _goProClassnames = missionNamespace getVariable "CFM_goProHelmets";
	if (isNil "_goProClassnames") exitWith {false};
	private _headgear = headgear _this;
	_headgear in _goProClassnames;
};

CFM_fnc_doCheckTurretLocality = {
	params["_operator"];

	if !(IS_OBJ(_operator)) exitWith {false};

	_operator call CFM_fnc_isUAV;
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

	private _typeOp = _operator call CFM_fnc_getOperatorClass;
	private _camType = _operator call CFM_fnc_cameraType;
	private _canSwitchTi = _operator getVariable ["CFM_canSwitchTi", 0];
	private _canSwitchNvg = _operator getVariable ["CFM_canSwitchNvg", 0];
	private _tiTable = _operator getVariable ["CFM_tiTable", []];
	private _nvgTable = _operator getVariable ["CFM_nvgTable", []];
	if (!(_canSwitchTi isEqualTo false) && ((_tiTable isEqualTo []) && {!(_tiTable isEqualTo createHashMap)})) then {
		private _tiTurret = getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "thermalMode");
		private _tiPilot = if (_camType in [DRONETYPE]) then {
			getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "thermalMode");
		} else {_tiTurret};
		
		private _tiModesTable = missionNamespace getVariable ["CFM_tiModesTable", createHashMap];

		_tiPilot = _tiPilot apply {
			_tiModesTable getOrDefault [_x, 2]
		};
		_tiTurret = _tiTurret apply {
			_tiModesTable getOrDefault [_x, 2]
		};

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
		private _nvgTurret = "NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide" >> "visionMode"));
		private _nvgPilot = if (_camType in [DRONETYPE]) then {
			"NVG" in (getArray (configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "visionMode"));
		} else {_nvgTurret};

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
    params [["_player", objNull], ["_renderTarget", "rendertarget0"], ["_settings", ""]];
    
    disableSerialization;
    
    [_player] call CFM_fnc_closePIPwindow;
    sleep 0.01;

    _renderTarget cutRsc ["RscTitleDisplayEmpty", "PLAIN"];
    waitUntil {!(isNil {uiNamespace getVariable "RscTitleDisplayEmpty"})};
    private _display = uiNamespace getVariable "RscTitleDisplayEmpty";
    
    _player setVariable ["CFM_currentRscLayer", _renderTarget];
    _player setVariable ["CFM_currentDisplay", _display];
    
	_settings = if ((_settings isEqualType "") && {!(_settings isEqualTo "")}) then {
		_settings
	} else {
    	missionNamespace getVariable ["CFM_PIPsettings", DEFAULT_PIP_SETTINGS_STR]; 
	};
	private _settingsCompiled = call compile _settings; 
	if ((isNil "_settingsCompiled") || {!(_settingsCompiled isEqualType [])}) then {
		_settingsCompiled = DEFAULT_PIP_SETTINGS;
	};
    _settingsCompiled params [["_size", 0.2], ["_offsetX", 1], ["_offsetY", 0.8]];

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
	params[["_player", PLAYER_]];
	private _renderTarget = _player getVariable ["CFM_currentRscLayer", ""];
	_renderTarget cutFadeOut 0;
    private _prevDisplay = _player getVariable ["CFM_currentDisplay", displayNull];
    if (!isNull _prevDisplay) then { _prevDisplay closeDisplay 1; };
};

CFM_fnc_setHandDisplay = {
	params[["_player", PLAYER_], ["_render", true], ["_fullscreen", false]];

	private _renderTarget = _player getVariable ["CFM_currentR2T", ""];
	private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
	private _isDialog = _fullscreen || {_isAllHandMonsDialogs || (_player getVariable ["CFM_isHandMonitorDisplay", _isAllHandMonsDialogs])};

	if (_render && {IS_VALID_R2T(_renderTarget)}) then {
		private _settings = if (_isDialog) then {
			disableSerialization;
			private _disp = (findDisplay 46) createDisplay "RscDisplayCFM";
			uiNamespace setVariable ["CFM_tabletDisplay", _disp];
			PLAYER_ setVariable ["CFM_tabletDisplayIsOpened", true];
			PLAYER_ setVariable ["CFM_turnedOffLocal", false];
			[_disp, _player] spawn {
				params['_disp', '_player'];
				// for safety
				waitUntil {uiSleep 1; isNull _disp};
				[_player, false] call CFM_fnc_setHandDisplay;
			};
			"[0.9, 0.5, 0.5]"
		} else {
			""
		};
		[_player, _renderTarget, _settings] spawn CFM_fnc_createPIPwindow;
	} else {
		if (_isDialog) then {
			private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
			_disp closeDisplay 1;
			uiNamespace setVariable ["CFM_tabletDisplay", displayNull];
		};
		[_player] call CFM_fnc_closePIPwindow;
	};
};

CFM_fnc_onDisplayUnload = {
	params[["_display", displayNull]];
	disableSerialization;
	private _currentFullscreenedMonitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", PLAYER_];
	_currentFullscreenedMonitor setVariable ["CFM_tabletDisplayIsOpened", false];
	if (_currentFullscreenedMonitor isEqualTo PLAYER_) then {
		[PLAYER_] call CFM_fnc_turnOffMonitorLocal;
	} else {
		[_currentFullscreenedMonitor, false] call CFM_fnc_setHandDisplay;
	};
	if (missionNamespace getVariable ["CFM_isInFullScreen", false]) then {
		[] call CFM_fnc_exitFullScreen;
	};
	missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
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

CFM_fnc_turnOffMonitorLocal = {
	params["_monitor"];
	[_monitor, false, "", true] call CFM_fnc_setMonitorTexture;
	_monitor setVariable ["CFM_turnedOffLocal", true]; 
};

CFM_fnc_turnOnMonitorLocal = {
	params["_monitor"];
	[_monitor] call CFM_fnc_setMonitorTexture;
	_monitor setVariable ["CFM_turnedOffLocal", false]; 
};

CFM_fnc_takeUAVcontorls = { 
	params ["_monitor"]; 

	private _drone = _monitor getVariable ["CFM_connectedOperator", objNull]; 
	private _errtext = "Can't connect to drone";

	if !(IS_OBJ(_drone)) exitWith {};

	private _dSide = side _drone;
	private _playerSide = side PLAYER_;
	private _sameSide = _dSide isEqualTo _playerSide;
	private _canHack = missionNamespace getVariable ["CFM_canHackDrone", false];

	if (!_canHack && !_sameSide) exitWith {
		hint _errtext;
	};
	if (!_sameSide) exitWith {
		// do hack
		[_monitor, _drone, _playerSide] spawn {
			params ["_monitor", "_drone", "_playerSide"];

			[[_drone, _playerSide, clientOwner], {
				params ["_drone", "_side", "_netId"];
				deleteVehicleCrew _drone;
				_side createVehicleCrew _drone;
			}] remoteExecCall ["call", _drone];

			hint "Hacking drone...";
			sleep (missionNamespace getVariable ["CFM_hackDroneTime", 5]);

			private _newSide = side _drone;
			if !(_newSide isEqualTo _playerSide) exitWith {
				hint "Failed to hack drone";
			};

			hint "Drone hacked!";

			[_monitor] spawn CFM_fnc_takeUAVcontorls;
		};
	};

	private _dDriver = driver _drone;
	private _dGunner = gunner _drone;
	private _controler = ([_dDriver, _dGunner] select {IS_OBJ((remoteControlled _x))})#0;

	if (isNil "_controler") then {
		_controler = objNull;
	};
	if (IS_OBJ(_controler)) exitWith {
		hint _errtext;
	};

	private _bot = _dDriver;
	private _currTurret = _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH]; 
	if (_currTurret isEqualTo GUNNER_TURRET_PATH) then {
		_bot = _dGunner;
		if (isNull _bot) then {
			_bot = _dDriver;
		};
	};
	if (isNil "_bot" || {!IS_OBJ(_bot)}) exitWith {
		hint _errtext;
	};

	PLAYER_ connectTerminalToUAV objNull;
	PLAYER_ switchCamera "internal";

	hint "Connecting...";
	sleep 0.3;
	hint "";

	private _connect = PLAYER_ connectTerminalToUAV _drone;

	if !(_connect) exitWith {
		hint _errtext;
	};

	[] call CFM_fnc_exitFullScreen;
	PLAYER_ remoteControl (_bot);
	_drone switchCamera "internal";
};

CFM_fnc_monitorSwitchTi = {
	params["_monitor"];
	["switchTi"] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_monitorToggleNVG = {
	params["_monitor"];
	["switchNvg"] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_monitorNextTurretCamera = {
	params["_monitor"];
	["nextTurret"] CALL_OBJCLASS("Monitor", _monitor);
};

CFM_fnc_disconnectMonitorFromOperatorKeybind = {
	[] call CFM_fnc_exitFullScreen;
	_this call CFM_fnc_disconnectMonitorFromOperator;
};

CFM_fnc_fixFeedKeybind = {
	[] call CFM_fnc_exitFullScreen;
	[] call CFM_fnc_fixFeed;
};

CFM_fnc_turnOnOffMonitorLocalKeybind = {
	[] call CFM_fnc_exitFullScreen;
	if (_this call CFM_fnc_turnOffActionCondition) then {
		_this call CFM_fnc_turnOffMonitorLocal;
	} else {
		_this call CFM_fnc_turnOnMonitorLocal;
	};
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
	if !(missionNamespace getVariable ["CFM_isInFullScreen", false]) exitWith {};

	private _monitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", objNull];
	private _exited = if (IS_OBJ(_monitor)) then {
		["monitorExitFullScreen", [_monitor], _monitor, false] CALL_OBJCLASS("Monitor", _monitor);
	} else {false};

	if (!(isNil "_exited") && {(_exited isEqualTo true)}) exitWith {};

	hint "";
	cutText ["", "PLAIN"];
	false setCamUseTI 0;
	camUseNVG false;
	private _currCam = missionNamespace getVariable ["CFM_currentFullScreenCam", objNull];
	if !(IS_OBJ(_currCam)) exitWith {
		private _currCamData = (allCameras select {(_x#3) isEqualTo "Internal"})#0;
		if (isNil "_currCamData") exitWith {
			"ERROR CFM_fnc_exitFullScreen: cant find current Internal camera!" WARN;
		};
		_currCam = _currCamData#0;
		_currCam cameraEffect ["Terminate", "back"];
		PLAYER_ switchCamera "INTERNAL";
	};
	private _r2t = missionNamespace getVariable ["CFM_r2tOfFullScreenCam", ""];
	missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
	missionNamespace setVariable ["CFM_currentFullScreenCam", nil];
	missionNamespace setVariable ["CFM_r2tOfFullScreenCam", nil];
	missionNamespace setVariable ["CFM_isInFullScreen", false];
	if !(IS_VALID_R2T(_r2t)) exitWith {
		_currCam cameraEffect ["Terminate", "back"];
		PLAYER_ switchCamera "INTERNAL";
	};
	_currCam cameraEffect ["Internal", "back", _r2t];
	PLAYER_ switchCamera "INTERNAL";
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

	private _monitor = if (_mNetId isEqualType "") then {objectFromNetId _mNetId} else {_mNetId}; 
	private _operator = if (_oNetId isEqualType "") then {objectFromNetId _oNetId} else {_oNetId}; 

	if !(IS_OBJ(_monitor)) exitWith {};
	if (_start && {!(IS_OBJ(_operator))}) exitWith {};

	private _isWaiting = _monitor getVariable ["CFM_waitingForStart", false]; 

	if (_isWaiting && _start) exitWith {};

	_monitor setVariable ["CFM_waitingForStart", _start];

	if (_start) then {
		waitUntil {
			if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {false};
			if !(_operator getVariable ["CFM_operatorSet", false]) exitWith {false};
			private _optimizeDistance = missionNamespace getVariable ["CFM_optimizeByDistance", OPTIMIZE_MONITOR_FEED_DIST];
			_optimizeDistance = call compile _optimizeDistance;
			if (_optimizeDistance <= 0) exitWith {true};
			private _dist = _monitor distance PLAYER_;
			private _isClose = _dist < _optimizeDistance;
			_start = _monitor getVariable ["CFM_waitingForStart", true];
			if (_isClose) exitWith {true};
			if !(_start) exitWith {true};
			sleep 1;
			_isClose
		};
	};
	if (_start) then { 
		if (_monitor getVariable ["CFM_feedActive", false]) then {
			[_monitor] call CFM_fnc_stopOperatorFeed;
		}; 
		[_monitor, _operator] call CFM_fnc_startOperatorFeed; 
	} else {
		if !(_monitor getVariable ["CFM_feedActive", true]) exitWith {};
		[_monitor] call CFM_fnc_stopOperatorFeed;
	}; 
	_monitor setVariable ["CFM_waitingForStart", false]; 
}; 

CFM_fnc_remoteExec = {
	params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", true], ["_call", false, [false]]];

	if (_func isEqualType {}) then {
		_args = [_args, _func];
		_func = if (_call) then {"call"} else {"spawn"};
	};
	if !(_func isEqualType "") exitWith {format["CFM_fnc_remoteExec ERROR: func not str or code. Func type: %1. Func value: %2", typeName _func, _func] WARN};

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
			_id = trim (_idArr#1);
			if !(_id isEqualType "") then {
				_id = str _id;
			};
		};
		_jip = "CFM_jip_remote_exec_id_" + _id;
	};

	if (_targets in [PLAYER_, false, clientOwner]) exitWith {
		if (_func isEqualTo "call") exitWith {
			(_args#0) call (_args#1)
		};
		if (_func isEqualTo "spawn") exitWith {
			(_args#0) spawn (_args#1)
		};
		private _func = missionNamespace getVariable [_func, {format["CFM_fnc_remoteExec ERROR: func '%1' not found!", _func] WARN}];
		if (_call) then {
			_args call _func
		} else {
			_args spawn _func
		};
	};

	if (_call) then {
		_args remoteExecCall [_func, _targets, _jip];
	} else {
		_args remoteExec [_func, _targets, _jip];
	};
};

CFM_fnc_fixFeed = {
	private _monitors = missionNamespace getVariable ["CFM_Monitors", []];
	{
		[_x] spawn CFM_fnc_resetFeed;
	} forEach _monitors;

	hint "
	If you still have no feed try reseting PIP setting value!
	Якщо досі немає картинки, спробуйте переставити параметр PIP в налаштуваннях!
	";
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

	if (_cls isEqualTo DUMMY_CLASSNAME) exitWith {
		TYPE_STATIC
	};
	if ((_obj isKindOf "Man") || {_classType isEqualTo TYPE_UNIT}) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_HELM) exitWith {
		GOPRO
	};
	if (_classType isEqualTo TYPE_UAV) exitWith {
		DRONETYPE
	};
	if (_classType isEqualTo TYPE_VEH) exitWith {
		TYPE_VEH
	};
	_classType
};

CFM_fnc_validClassType = {
	params["_cls"];

	if (_cls isEqualTo DUMMY_CLASSNAME) exitWith {TYPE_STATIC};

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

CFM_fnc_getTurretIndex = {
	params["_t", ["_path", [0]]];

	switch (_t) do {
		case "driver": {-1};
		case "turret": {
			private _pathIndex = _path#0;
			_pathIndex
		};
		default {
			private _i = TURRET_INDEX(_t);
			if (_i isEqualType 1) exitWith {_i};
			-2
		};
	};
};

CFM_fnc_getOperatorClass = {
	if (IS_OBJ(_this)) exitWith {typeOf _this};
	typeName _this;
};

CFM_fnc_setTurretParams = {
	params[["_operator", objNull]];
	_this = _this - [_operator];
	["setTurretParams", _this] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_defineCameraMovementOptions = {
	params[["_option", -1]];

	private _defFalse = [false, []];
	if (_option isEqualTo -1) exitWith {_defFalse};
	if (_option isEqualTo 0) exitWith {_defFalse};
	if (_option isEqualTo 1) exitWith {[true, []]};
	if (_option isEqualTo true) exitWith {[true, []]};
	if (_option isEqualTo false) exitWith {_defFalse};
	if !(_option isEqualType []) exitWith {_defFalse};

	private _option = (+_option) select {_x isEqualType 1};
	private _sum = 0;
	{
		_sum = _sum + _x;
	} forEach _option;

	if (_sum isEqualTo 0) exitWith {_defFalse};

	_option params [["_leftDegrees", 0], ["_rightDegrees", 0], ["_upDegrees", 0], ["_downDegrees", 0]];

	[true, [_leftDegrees, _rightDegrees, _upDegrees, _downDegrees]]
};

CFM_fnc_hasUAVterminal = {
	'terminal' in (toLower (_this getSlotItemName 612))
};

CFM_fnc_isUAV = {
	(_this isKindOf "Air") && {(getNumber (configFile >> "CfgVehicles" >> (typeOf _this) >> "isUav")) isEqualTo 1}
};

CFM_fnc_getPlayer = {
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
};

CFM_fnc_copyMenuActionsToObj = {
	params["_from", "_to"];

	private _actions = _plr getVariable ["CFM_mainActions", []];

	if (!(_actions isEqualType []) || {(_actions isEqualTo [])}) exitWith {
		"CAN'T COPY HAND MONITOR ACTIONS TO NEW CONTROLLED UNIT!" WARN;
		false
	};

	private _newActions = [];

	{
		if !(_x isEqualType 1) then {continue};
		private _actionParams = _from actionParams _x;
		_actionParams deleteAt 10;
		_actionParams deleteAt 11;
		private _id = _to addAction _actionParams;
		_newActions pushBack _id;
	} forEach _actions;

	_unit setVariable ["CFM_copiedActions", _newActions];
	_unit setVariable ["CFM_actionsSet", true];
	true
};

CFM_fnc_compareVectors = {
	params[["_v1", []], ["_v2", []], ["_tolerance", DO_INTERPOLATE_TOLERANCE]];

	if (_tolerance <= 0) exitWith {
		_v1 isEqualTo _v2
	};

	private _dist = _v1 distance _v2;

	(_dist) < _tolerance
};

CFM_fnc_getTargetMonitor = {
	private _watchingAtMonitor = [PLAYER_] call CFM_fnc_isWatchingAtMonitor;
	if (_watchingAtMonitor) exitWith {cursorObject};
	if ((player getVariable ["CFM_isHandMonitor", false]) isEqualTo true) exitWith {player};
	objNull
};

CFM_fnc_initActionConditions = {
	#define HAND_MON_CONDITION if ([_target] call CFM_fnc_handMonitorMenuActionCondition) exitWith {false};
	#define IS_MONITOR_ON ;
	#define IS_MONITOR_ON if ((_target getVariable ["CFM_isHandMonitor", false]) && {_target getVariable ['CFM_turnedOffLocal', false]}) exitWith {false};
	
	CFM_fnc_isWatchingAtMonitor = {
		params[["_target", PLAYER_]];
		(!(isNil {cursorObject getVariable "CFM_originalTexture"})) && {!(cursorObject isEqualTo _target)};
	};
	CFM_fnc_handMonitorMenuActionCondition = {
		params["_target"];

		private _isHandMonitor = _target getVariable ["CFM_isHandMonitor", false];
		if !(_isHandMonitor) exitWith {false};
		if !(_target isEqualTo PLAYER_) exitWith {true};

		[_target] call CFM_fnc_isWatchingAtMonitor;
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
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && !(_target getVariable ['CFM_maxZoomed', false])
	};
	CFM_fnc_zoomActionsCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		_target getVariable ['CFM_feedActive', false]
	};
	CFM_fnc_operatorZoomActionsCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && {
			!(_target getVariable ['CFM_currentCameraIsStatic', false])
		}
	};
	CFM_fnc_connectDroneActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOperatorIsDrone', false]) &&
			{PLAYER_ call CFM_fnc_hasUAVterminal}
		}
	};
	CFM_fnc_fixFeedActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false])
	};
	CFM_fnc_switchCameraToGunnerActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOpHasTurrets', false]) && {
				((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [-1])
			}
		}
	};
	CFM_fnc_switchCameraToPilotActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOpHasTurrets', false]) && {
				((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [0])
			}
		}
	};
	CFM_fnc_switchCameraTurretActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		IS_MONITOR_ON
		(_target getVariable ['CFM_feedActive', false]) && {
			(_target getVariable ['CFM_currentOpHasTurrets', false])
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
		IS_MONITOR_ON
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
		IS_MONITOR_ON
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
		if !(missionNamespace getVariable ['CFM_canFullscreen', true]) exitWith {false};
		if !(_target getVariable ['CFM_feedActive', false]) exitWith {false};
		if !(_target getVariable ['CFM_canFullScreen', false]) exitWith {false};
		// private _connectedOperator = _target getVariable ['CFM_connectedOperator', objNull];
		// if (_connectedOperator getVariable ['CFM_hasGoPro', false]) exitWith {false};
		IS_MONITOR_ON
		if (
			(_target getVariable ['CFM_isHandMonitor', false]) &&
			{(_target getVariable ['CFM_isHandMonitorDisplay', false]) || 
			{MGVAR ["CFM_allHandMonitorsAreDisplays", false]}}
		) exitWith {false};
		focusOn == PLAYER_
	};
	CFM_fnc_exitFullScreenActionCondition = {
		params["_target"];
		focusOn != PLAYER_
	};
	CFM_fnc_watchTabletActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) &&
		{(_target getVariable ["CFM_isHandMonitor", false]) &&
		{(_target getVariable ["CFM_turnedOffLocal", false])}}
	};
	CFM_fnc_stopWatchTabletActionCondition = {
		params["_target"];
		HAND_MON_CONDITION
		(_target getVariable ['CFM_feedActive', false]) &&
		{(_target getVariable ["CFM_isHandMonitor", false]) &&
		{!(_target getVariable ["CFM_turnedOffLocal", false])}}
	};
};

#define CAMERA_MOVE_DIRECTIONS ["up", "down", "left", "right"]
#define CAMERA_MOVE_STEP 5

CFM_fnc_rotateAroundAxis = {
	params ["_v", "_axis", "_angle"];
	private _c = cos _angle;
	private _s = sin _angle;
	(_v vectorMultiply _c) vectorAdd 
	((_axis vectorCrossProduct _v) vectorMultiply _s) vectorAdd 
	(_axis vectorMultiply ((_axis vectorDotProduct _v) * (1 - _c)))
};

CFM_fnc_transformTurret = {
    params ["_dir", "_up", "_pitch", "_yaw"];

    // 1. Глобальный Yaw (вокруг оси [0, 0, 1])
    if (_yaw != 0) then {
        private _worldZ = [0, 0, 1];
        _dir = [_dir, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
        _up = [_up, _worldZ, _yaw] call CFM_fnc_rotateAroundAxis;
    };

    // 2. Локальный Pitch
    if (_pitch != 0) then {
        // Вычисляем "право" ПОСЛЕ поворота по Yaw, чтобы оно было актуальным
        private _side = _dir vectorCrossProduct _up;
        
        _dir = [_dir, _side, _pitch] call CFM_fnc_rotateAroundAxis;
        _up = [_up, _side, _pitch] call CFM_fnc_rotateAroundAxis;
    };

    [_dir, _up]
};

CFM_fnc_cameraMove = {
	params["_operator", ["_turretIndex", -1], ["_direction", ""], ["_step", CAMERA_MOVE_STEP]];

	private _axisAngles = switch (_direction) do {
		case "up": {
			[0, _step]
		};
		case "down": {
			[0, -_step]
		};
		case "right": {
			[-_step, 0]
		};
		case "left": {
			[_step, 0]
		};
		default {[0,0]};
	};

	if (_axisAngles isEqualTo [0,0]) exitWith {false};

	["moveCamera", [_turretIndex, _axisAngles], _operator, false] CALL_OBJCLASS("Operator", _operator);
};

CFM_fnc_monitorCameraMove = {
	params["_monitor", ["_direction", ""]];

	private _canMove = _monitor getVariable ["CFM_currentCameraCanMove", false];
	if !(_canMove isEqualTo true) exitWith {false};

	private _directionIndex = CAMERA_MOVE_DIRECTIONS find _direction;
	if (_directionIndex == -1) exitWith {false};

	private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];

	if (!IS_OBJ(_camera)) exitWith {false};

	private _currZoom = _monitor getVariable ["CFM_zoomFov", 1];
	private _sensitivity = (MGVAR ["CFM_cameraMoveSensitivity", 5]);
	private _step = _sensitivity * _currZoom;
	private _movementRestrictions = _monitor getVariable ["CFM_currentCameraMoveRestrictions", [180,180,180,180]];
	private _currentCameraMoves = _monitor getVariable ["CFM_currentCameraMoves", [0,0,0,0]];
	private _directionRestriction = _movementRestrictions param [_directionIndex, 0];
	private _currentCameraMove = _currentCameraMoves param [_directionIndex, 0];
	private _newMove = _currentCameraMove + _step;

	if (_directionRestriction < 1) exitWith {false};
	if (_newMove > _directionRestriction) exitWith {false};

	private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
	private _turretIndex = _monitor getVariable ["CFM_currentTurret", [-1]];

	[_operator, _turretIndex, _direction, _step] call CFM_fnc_cameraMove;
};

CFM_fnc_monitorCameraTurnUp = {
	params["_monitor"];

	[_monitor, "up"] call CFM_fnc_monitorCameraMove;
};

CFM_fnc_monitorCameraTurnDown = {
	params["_monitor"];

	[_monitor, "down"] call CFM_fnc_monitorCameraMove;
};

CFM_fnc_monitorCameraTurnLeft = {
	params["_monitor"];

	[_monitor, "left"] call CFM_fnc_monitorCameraMove;
};

CFM_fnc_monitorCameraTurnRight = {
	params["_monitor"];

	[_monitor, "right"] call CFM_fnc_monitorCameraMove;
};