
#define SET_VARS_INIT_GLOBAL true
#define DO_OVERWRITE_CURRENT_MOVE false

OBJCLASS(Operator)

	IS_SINGLETON
	
	SET_SELF_VAR("_operator");

	FIELD ["_canSwitchTi", false];
	FIELD ["_canSwitchNvg", false];
	FIELD ["_opHasTurrets", false];
	FIELD ["_turrets", [DRIVER_TURRET_PATH]];
	FIELD ["_cameraType", ""];
	FIELD ["_operatorName", ""];
	FIELD ["_operatorId", -1];
	FIELD ["_hasGoPro", false];
	FIELD ["_canFeed", false];
	FIELD ["_canMoveCameraByDefault", false];
	FIELD ["_cameraMoveRestrictionsByDefault", []]; // [degrees up, degrees down, degrees left, degrees right]
	FIELD ["_cameraZoomSmoothDefault", false]; 
	FIELD ["_classType", ""];
	FIELD ["_objClass", ""];
	FIELD ["_monitorsSet", createHashMap];
	FIELD ["_tiTable", createHashMap];
	FIELD ["_nvgTable", createHashMap];
	FIELD ["_operatorSet", false];
	FIELD ["_isFeeding", false];
	FIELD ["_isDroneFeed", false];	
	FIELD ["_isMavic", false];	
	FIELD ["_isFPV", false];	
	FIELD ["_staticCamOffset", NULL_VECTOR];	
	FIELD ["_isStaticCam", false];	
	FIELD ["_opSides", []];	
	FIELD ["_turretsInstances", createHashMap];	
	FIELD ["_opCameraPosFunc", CAM_POS_FUNC_DEF];
	FIELD ["_hasActiveTurretsObjects", -1];
	FIELD ["_activeTurretsObjects", createHashMap];


	// PP - point params types
	#define PP_NONE -1
	#define PP_STATIC 0
	#define PP_VEH_STATIC 1
	#define PP_VEH_TURRET 2
	#define TimeToMoveSmoothCoef 0.2

	METHOD("Init") {
		// should be executed globaly
		params[["_sides", []], ["_turrets", []], ["_hasTInNvg", [0, 0]], ["_name", ""], ["_params", []]];

		private _global = SET_VARS_INIT_GLOBAL;

		if !(IS_VALID_OP(_operator)) exitWith {1};

		if (_classType isEqualTo "") then {
			_classType =  [_operator call CFM_fnc_getOperatorClass] call CFM_fnc_validClassType;
		};
		if !(_classType in VALID_CLASS_TYPES) exitWith {"Init Operator: Invalid class type passed" WARN; 2};

		_operator setVariable ["CFM_classType", _classType, _global];


		// CAM TYPE
		_cameraType = [_operator] call CFM_fnc_cameraType;
		_operator setVariable ["CFM_cameraType", _cameraType, _global];

		_operator setVariable ["CFM_canFeed", true, _global];
		switch (_cameraType) do {
			case DRONETYPE: {
				_isDroneFeed = true;
				_operator setVariable ["CFM_isDroneFeed", _isDroneFeed, _global];
			};
			case TYPE_VEH: {
				_operator setVariable ["CFM_isVehFeed", true, _global];
			};
			default {};
		};
		
		// OTHER PARAMS
		if !(_params isEqualType []) then {_params = [_params]};
		_params params [
			["_canMoveCameraByDefaultSet", -1],
			["_cameraZoomSmoothDefault", true, [true]]
		];

		_objClass = toLower (_operator call CFM_fnc_getOperatorClass);
		_operator setVariable ["CFM_objClass", _objClass, _global];

		_isFPV = (("fpv" in _objClass) || {("crocus" in _objClass)});
		_isMavic = ("mavik_3" in _objClass);
		_hasGoPro = _classType in [TYPE_UNIT, TYPE_HELM];
		_operator setVariable ["CFM_hasGoPro", _hasGoPro, _global];
		_operator setVariable ["CFM_isFPV", _isFPV, _global];
		_operator setVariable ["CFM_isMavic", _isMavic, _global];
		
		// CAN MOVE CAMERA
		if ((_classType isEqualTo TYPE_UAV) && {
			!(_canMoveCameraByDefaultSet isEqualTo false) && {
				!_isFPV
			}
		}) then { // && {MGVAR ["CFM_canMoveDroneCameras", false]}
			_canMoveCameraByDefaultSet = true;
		};
		private _moveParams = [_canMoveCameraByDefaultSet, _self] call CFM_fnc_defineCameraMovementOptions;
		_moveParams params [["_canMoveCameraByDefault", false], ["_cameraMoveRestrictionsByDefault", [], [[]]]];
		_operator setVariable ["CFM_canMoveCameraByDefault", _canMoveCameraByDefault, _global];
		_operator setVariable ["CFM_cameraMoveRestrictionsByDefault", +_cameraMoveRestrictionsByDefault, _global];
		_operator setVariable ["CFM_cameraZoomSmoothDefault", !_hasGoPro && _cameraZoomSmoothDefault, _global];

		if (_classType isEqualTo TYPE_STATIC) then {
			_isStaticCam = true;
			_operator setVariable ["CFM_isStaticCam", _isStaticCam, _global];
		};

		// NVG AND TI
		_hasTInNvg params ["_ti", "_nvg"];
		if !(_ti isEqualType true) then {
			_ti = true;
		};
		if !(_nvg isEqualType true) then {
			_nvg = true;
		};
		([_operator] call CFM_fnc_setupNvgAndTI) params [["_tiTable", createHashMap], ["_nvgTable", createHashMap], ["_canSwitchTi", false], ["_canSwitchNvg", false]];
		_canSwitchTi = _ti && _canSwitchTi;
		_canSwitchNvg = _nvg && _canSwitchNvg;
		_operator setVariable ["CFM_tiTable", _tiTable, _global];
		_operator setVariable ["CFM_nvgTable", _nvgTable, _global];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi, _global];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg, _global];


		// TURRETS
		["DefineTurretsParams", [_turrets]] CALL_OBJCLASS("Operator", _self);


		// CHECK NVG TI
		private _turrets = _self getVariable ["CFM_turrets", []];
		private _turrCount = count _turrets;
		if (_turrCount == 1) then {
			// if turrets is one and nvg and ti are two we set ti and nvg for any ti/nvg table turr have it
			private _turr = _turrets#0;
			private _turrIndex = TURRET_INDEX(_turr);
			if (_turrIndex isEqualTo -1) then {
				// TI
				call {
					private _tiForDriver = _tiTable get _turrIndex;
					if (isNil "_tiForDriver") exitWith {};
					if (count _tiForDriver != 0) exitWith {};
					private _tiForGunner = _tiTable get 0;
					if (isNil "_tiForGunner") exitWith {};
					if (count _tiForGunner == 0) exitWith {};
					_tiForGunner = +_tiForGunner;
					_tiTable = createHashMap;
					_tiTable set [-1, _tiForGunner];
				};
				// NVG
				call {
					private _nvgForDriver = _nvgTable get _turrIndex;
					if (isNil "_nvgForDriver") exitWith {};
					if (_nvgForDriver isEqualTo true) exitWith {};
					private _nvgForGunner = _nvgTable get 0;
					if (isNil "_nvgForGunner") exitWith {};
					if (_nvgForDriver isEqualTo false) exitWith {};
					_nvgForGunner = +_nvgForGunner;
					_nvgTable = createHashMap;
					_nvgTable set [-1, _nvgForGunner];
				};
			};
		};

		// SIDE
		private _defaultSide = [(getNumber (configFile >> "CfgVehicles" >> _objClass >> "side"))] call BIS_fnc_sideType;
		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};
		if (_sides isEqualTo []) then {
			_sides = [_defaultSide];
		};
		_operator setVariable ["CFM_opSides", _sides, _global];


		// ADD OP
		["addOperator", [_operator]] CALL_CLASS("DbHandler");

		if (_name isEqualTo "") then {
			_name = switch (_cameraType) do {
				case GOPRO: {
					format["%1: %2", groupId group _self, name _self]
				};
				case TYPE_STATIC: {
					private _operatorId = _self getVariable ["CFM_operatorId", 0];
					_self getVariable ["CFM_staticCameraID", "Camera " + str _operatorId];
				};
				default {
					private _group = groupId group _self;
					private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _self) >> "displayName");
					if (_group isEqualTo "") then {
						_dispName
					} else {
						format["%1: %2", _group, _dispName]
					};
				};
			};
		};
		_operator setVariable ["CFM_operatorName", _name, _global];

		_operator setVariable ["CFM_operatorSet", true, _global];

		true
	};
	METHOD("DefineTurretsParams") {
		params[["_turretsParamsInit", []]];
		
		if (_turretsParamsInit isEqualTo []) then {
			private _fullCrew = fullCrew [_self, "", true];
			private _crewCount = count _fullCrew;

			if (_crewCount == 0) exitWith {
				if (_cameraType isEqualTo GOPRO) then {
					_turretsParamsInit = [-1];
				};
			};

			private _hasGunner = (_fullCrew findIf {(_x#1) isEqualTo "gunner"}) != -1;
			_turretsParamsInit = [-1];
			if ((_crewCount > 1) && _hasGunner && {_cameraType isEqualTo DRONETYPE}) then {
				_turretsParamsInit = [DRIVER_TURRET_PATH, GUNNER_TURRET_PATH];
			};
		};

		_opHasTurrets = count _turretsParamsInit > 1;
		_operator setVariable ["CFM_opHasTurrets", _opHasTurrets, SET_VARS_INIT_GLOBAL]; 

		private _turrets = [];
		private _validTurretInitParams = [];
		{
			private _turret = _x;
			if !(_turret isEqualType []) then {
				_turret = [_turret];
			};
			if !((_turret#0) isEqualType 1) then {
				private _nextTurret = if (_turrets isEqualTo []) then {-1} else {(_turrets#-1) + 1};
				_turret = [_nextTurret, _turret];
			};
			_turret params [["_turretIndex", -1], ["_params", []]];
			_validTurretInitParams pushBack _turret;
			_turretIndex = TURRET_INDEX(_turretIndex);
			_turrets pushBackUnique _turretIndex;
		} forEach _turretsParamsInit;

		_operator setVariable ["CFM_turrets", _turrets, SET_VARS_INIT_GLOBAL]; 

		{
			_x params [["_turretIndex", -1], ["_params", []]];
			private _turretArgs = [_turretIndex] + _params;
			private _args = [_operator] + _turretArgs;
			_args call CFM_fnc_setTurretParams;
		} forEach _validTurretInitParams;

		if (isServer) then {
			_self call CFM_fnc_checkOperatorTurrets;
		};

		_turretsInstances
	};
	METHOD("setTurretParams") {
		params [
			["_turretIndex", -1],
			["_turretObject", objNull]
		];
		if !(IS_OBJ(_turretObject)) then {
			_turretObject = _self;
		} else {
			if (isServer) then {
				if (_hasActiveTurretsObjects > 0) exitWith {};
				_hasActiveTurretsObjects = 0;
				_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, true];
			};
		};
		if (!(_this isEqualType [])) then {_this = [_this]};
		_this = [_self, _turretIndex] + (_this select [2, (count _this - 2) max 0]);
		private _turretInstanceId = TURRET_INSTANCE_ID(_turretIndex);
		if (_turretInstanceId < 0) then {
			_turretInstance = ([_turretObject, _this] NEW_OBJINSTANCE_GLOBAL("Turret", true));
			["NEW TURR", _self, _turretIndex, _turretInstance] RLOG
			_turretInstanceId = _turretInstance param [0, -1];
			if !(_turretInstanceId isEqualType 1) then {_turretInstanceId = -1};
		} else {
			["Init", _this] CALL_TURRET_INSTANCE(_turretIndex);
		};
		if (_turretInstanceId < 0) exitWith {};
		["NEW TURR 1", _self, _turretIndex, _turretsInstances] RLOG
		[_self, "CFM_turretsInstances", _turretIndex, [_turretInstanceId, _turretObject], true, SET_VARS_INIT_GLOBAL] call EFL_fnc_hashSetNet;
		["NEW TURR 2", _self, _turretIndex, _turretsInstances, _self getVariable ["CFM_turretsInstances", []]] RLOG
	};
	METHOD("setPointParams") {
		params[["_turretIndex", -1], ["_params", []]];

		_turretIndex = TURRET_INDEX(_turretIndex);

		["setPointParams", [_params]] CALL_TURRET_INSTANCE(_turretIndex);
	};
	METHOD("setDefaultPointAlignment") {
		{
			[_self, _x, -1] call CFM_fnc_setPointAlignment;
		} forEach _turrets;
	};
	METHOD("monitorConnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull], ["_reset", false]];

		if !(IS_OBJ(_monitor)) exitWith {};

		private _callerLocal = IS_OBJ(_caller) && {(local _caller)};

		_self setVariable ["CFM_isFeeding", true];
		_monitor setVariable ["CFM_monitorCanSwitchNvg", _canSwitchNvg];
		_monitor setVariable ["CFM_monitorCanSwitchTi", _canSwitchTi];
		_monitor setVariable ["CFM_currentOpHasTurrets", _opHasTurrets];
		_monitor setVariable ["CFM_currentCameraType", _cameraType];
		_monitor setVariable ["CFM_currentOperatorIsDrone", _isDroneFeed];

		["TurretChanged", [_monitor, _turret, false, _callerLocal, _reset]] CALL_OBJCLASS("Operator", _self);
	};
	METHOD("monitorConnectedLocalOperator") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		["addActiveOperator", [_operator]] CALL_CLASS("DbHandler");
		["TurretChangedLocalOperator", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
	};
	METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];
	};
	METHOD("monitorDisconnectedLocalOperator") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		["removeMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		if !([_self] call CFM_fnc_checkIfOperatorFeedsToAnyMonitor) then {
			["removeActiveOperator", [_operator]] CALL_CLASS("DbHandler");
		};
	};
	METHOD("TurretChanged") {
		params["_monitor", ["_turret", [-1]], ["_global", true], ["_globalUpdOp", true], ["_reset", false]];

		["TurretChanged", [_monitor, _global, _globalUpdOp, _reset]] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("TurretChangedLocalOperator") {
		params["_monitor", ["_turret", [-1]]];

		["TurretChangedLocalOperator", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("NextTurret") {
		params["_monitor", ["_currentTurret", [-1]]];

		private _curTurrIndex = TURRET_INDEX(_currentTurret);

		private _turretsIndexes = _turrets apply {TURRET_INDEX(_x)};
		private _turretsCount = count _turretsIndexes;

		private _currIndex = _turretsIndexes findIf {_x isEqualTo _curTurrIndex};
		private _nextIndex = _currIndex + 1;

		if ((_nextIndex + 1) > _turretsCount) then {
			_nextIndex = 0;
		};
		private _nextTurretIndex = _turretsIndexes select _nextIndex;

		["TurretChanged", [_monitor, [_nextTurretIndex], false, false], true] REMOTE_EXEC_OBJCLASS("Operator", _self);

		true
	};
	METHOD("addMonitor") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		["addMonitor", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("removeMonitor") {
		params[["_monitor", objNull], ["_turret", [-1]]];

		["removeMonitor", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("checkIfFeedsToAnyMonitor") {
		private _monitorsOnTurretsArray = values _monitorsSet;
		private _activeTurrets = {!(_x isEqualTo [])} count _monitorsOnTurretsArray;
		_activeTurrets > 0
	};
	METHOD("removeActiveTurret") {
		params[["_turretIndex", -1]];

		_activeTurretsObjects deleteAt _turretIndex;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects - 1) max 0;
		_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		_self setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
	};
	METHOD("addActiveTurret") {
		params[["_turretIndex", -1], ["_turretObject", objNull]];

		if (!(IS_OBJ(_turretObject)) || {_turretObject isEqualTo _self}) exitWith {false};

		_activeTurretsObjects set [_turretIndex, _turretObject];
		_hasActiveTurretsObjects = _hasActiveTurretsObjects max 0;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects + 1) max 0;
		_self setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		_self setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, MONITOR_VIEWERS_AND_SELF(false)];
		true
	};
	METHOD("moveCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2]];

		["moveCamera", [_axisAngles]] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("moveDroneCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2]];

		["moveDroneCamera", [_axisAngles]] CALL_TURRET_INSTANCE(_turret);
	};
	METHOD("setOperatorSides") {
		params[["_sides", civilian]];

		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};

		if (_sides isEqualTo []) exitWith {false};

		_opSides = _sides;
		_self setVariable ["CFM_opSides", _sides];
		true
	};
	METHOD("getOperatorName") {
		params[["_turret", -1]];

		private _turretName = ["getTurretName"] CALL_TURRET_INSTANCE(_turret);
		if (isNil "_turretName") exitWith {_operatorName};
		if (_turretName isEqualTo "") exitWith {_operatorName};
		_turretName
	};
OBJCLASS_END
