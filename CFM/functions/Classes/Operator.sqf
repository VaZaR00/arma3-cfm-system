
#define SET_VARS_INIT_GLOBAL true
#define DO_OVERWRITE_CURRENT_MOVE false

PUBLIC GLOBAL SINGLETON_CLASS(Operator)

	SET_SELF_VAR("_operator");

	// -----------------------------------------------
	// operator config
	PUBLIC GLOBAL FIELD ["_operatorName", ""];
	PRIVATE GLOBAL FIELD ["_operatorId", -1];
	PRIVATE GLOBAL FIELD ["_opSides", []];
	PUBLIC GLOBAL FIELD ["_canFeed", false];
	PRIVATE GLOBAL FIELD ["_classType", ""];
	PRIVATE GLOBAL FIELD ["_objClass", ""];
	PRIVATE GLOBAL FIELD ["_cameraType", ""];
	PRIVATE GLOBAL FIELD ["_hasGoPro", false];
	PRIVATE GLOBAL FIELD ["_isDroneFeed", false];
	PRIVATE GLOBAL FIELD ["_isMavic", false];
	PRIVATE GLOBAL FIELD ["_isFPV", false];
	PRIVATE GLOBAL FIELD ["_isStaticCam", false];
	PRIVATE GLOBAL FIELD ["_staticCamOffset", NULL_VECTOR];
	// -----------------------------------------------

	// -----------------------------------------------
	// operator state & connections
	PRIVATE GLOBAL FIELD ["_operatorSet", false];
	PRIVATE GLOBAL FIELD ["_isFeeding", false];
	// -----------------------------------------------

	// -----------------------------------------------
	// turrets config & instances
	PRIVATE GLOBAL FIELD ["_turrets", [DRIVER_TURRET_PATH]];
	PRIVATE GLOBAL FIELD ["_allTurrets", []];
	PRIVATE GLOBAL FIELD ["_disabledTurrets", []];
	PRIVATE GLOBAL FIELD ["_opHasTurrets", false];
	PRIVATE GLOBAL FIELD ["_turretsInstances", createHashMap];
	PRIVATE GLOBAL FIELD ["_cameraObjects", createHashMap];
	PRIVATE GLOBAL FIELD ["_hasActiveTurretsObjects", -1];
	PRIVATE GLOBAL FIELD ["_activeTurretsObjects", createHashMap];
	// -----------------------------------------------

	// -----------------------------------------------
	// optics, movement & defaults
	// NVG
	PUBLIC GLOBAL FIELD ["_canSwitchNvg", false];

	// TI
	PUBLIC GLOBAL FIELD ["_canSwitchTi", false];

	// Zoom & Movement defaults
	PRIVATE GLOBAL FIELD ["_cameraZoomSmoothDefault", false];
	PRIVATE GLOBAL FIELD ["_canMoveCameraByDefault", false];
	PRIVATE GLOBAL FIELD ["_cameraMoveRestrictionsByDefault", []]; // [degrees up, degrees down, degrees left, degrees right]
	// -----------------------------------------------


	// PP - point params types
	#define TimeToMoveSmoothCoef 0.2

	//----------- Internal -----------
	PRIVATE SE METHOD("Init") {
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
				isNil {
					if !(isNil "CFM_initDefPointAlignmentsSet") exitWith {};
					0 call CFM_fnc_setupDefPointAlignments;
				};
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
		private _moveParams = [_canMoveCameraByDefaultSet, _selfObj] call CFM_fnc_defineCameraMovementOptions;
		_moveParams params [["_canMoveCameraByDefault", false], ["_cameraMoveRestrictionsByDefault", [], [[]]]];
		_operator setVariable ["CFM_canMoveCameraByDefault", _canMoveCameraByDefault, _global];
		_operator setVariable ["CFM_cameraMoveRestrictionsByDefault", +_cameraMoveRestrictionsByDefault, _global];
		_operator setVariable ["CFM_cameraZoomSmoothDefault", !_hasGoPro && _cameraZoomSmoothDefault, _global];

		if (_classType isEqualTo TYPE_STATIC) then {
			_isStaticCam = true;
			_operator setVariable ["CFM_isStaticCam", _isStaticCam, _global];
		};

		// TURRETS
		["DefineTurretsParams", [_turrets]] CALL_SELF;

		// NVG AND TI INIT
		_canSwitchTi = _operator getVariable ["CFM_canSwitchTi", false];
		_canSwitchNvg = _operator getVariable ["CFM_canSwitchNvg", false];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi, _global];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg, _global];


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
					format["%1: %2", groupId group _selfObj, name _selfObj]
				};
				case TYPE_STATIC: {
					private _operatorId = _selfObj getVariable ["CFM_operatorId", 0];
					_selfObj getVariable ["CFM_staticCameraID", "Camera " + str _operatorId];
				};
				default {
					private _group = groupId group _selfObj;
					private _dispName = getText (configFile >> "CfgVehicles" >> (typeOf _selfObj) >> "displayName");
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
	PRIVATE SE METHOD("DefineTurretsParams") {
		params[["_turretsParamsInit", []]];
		
		if (_turretsParamsInit isEqualTo []) then {
			private _fullCrew = fullCrew [_selfObj, "", true];
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

		_allTurrets = +_turrets;
		_disabledTurrets = [];
		_operator setVariable ["CFM_allTurrets", _allTurrets, SET_VARS_INIT_GLOBAL];
		_operator setVariable ["CFM_disabledTurrets", _disabledTurrets, SET_VARS_INIT_GLOBAL];
		_operator setVariable ["CFM_turrets", _turrets, SET_VARS_INIT_GLOBAL]; 

		{
			_x params [["_turretIndex", -1], ["_params", []]];
			private _turretArgs = [_turretIndex] + _params;
			private _args = [_operator] + _turretArgs;
			_args call CFM_fnc_setTurretParams;
		} forEach _validTurretInitParams;

		if (isServer) then {
			_selfObj call CFM_fnc_checkOperatorTurrets;
		};

		_turretsInstances
	};
	PRIVATE LE GA METHOD("handleDisabledTurretViewers") {
		params[["_turretIndex", -1]];
		_turretIndex = TURRET_INDEX(_turretIndex);

		private _monitors = missionNamespace getVariable ["CFM_Monitors", []];
		private _hasOtherTurrets = (_turrets isNotEqualTo []);
		private _nextTurr = if (_hasOtherTurrets) then {TURRET_INDEX(_turrets select 0)} else {-2};

		{
			_x params [["_mon", objNull], ["_instId", -1]];
			if (!(IS_OBJ(_mon)) || {_instId < 1}) then {continue};
			private _monPair = [_mon, _instId];
			private _connOp = MON_GVAR(_mon, _instId, "CFM_connectedOperator", objNull);
			if (_connOp isEqualTo _selfObj) then {
				private _currTurr = TURRET_INDEX(MON_GVAR(_mon, _instId, "CFM_currentTurret", DRIVER_TURRET_PATH));
				if (_currTurr isEqualTo _turretIndex) then {
					if (_hasOtherTurrets) then {
						private _isVehSeat = MON_GVAR(_mon, _instId, "CFM_isVehSeatTablet", false);
						private _texSel = MON_GVAR(_mon, _instId, "CFM_textureSelection", NO_TEXTURE_SELECTION);
						private _seatKeys = MON_GVAR(_mon, _instId, "CFM_seatKeys", []);
						private _isSingleSeatPip = _isVehSeat && {_texSel < 0} && {(count _seatKeys) <= 1};
						if (_isSingleSeatPip) then {
							MON_SVARG(_mon, _instId, "CFM_currentTurret", [_nextTurr], true);
							if (hasInterface && {[_mon, _instId] call CFM_fnc_inVehicleTabletSeatCondition}) then {
								["TurretChanged", [_monPair, [_nextTurr], false, false]] CALL_SELF;
							};
						} else {
							private _monIsLocal = MON_GVAR(_mon, _instId, "CFM_isLocal", false);
							private _targets = MONITOR_VIEWERS_AND_SELF(_mon, _instId, _monIsLocal);
							["TurretChanged", [_monPair, [_nextTurr], false, false], [_targets, false]] REMOTE_EXEC_OBJCLASS("Operator", _selfObj);
						};
						MON_SVARG(_mon, _instId, "CFM_currentOpHasTurrets", _opHasTurrets, true);
					} else {
						[_monPair, _monPair] call CFM_fnc_disconnectMonitorFromOperator;
					};
				};
			};
		} forEach (+_monitors);
	};
	PRIVATE GE LA METHOD("syncContinuousMove") {
		params[["_turret", -1]];

		["syncContinuousMove", []] CALL_TURRET_INSTANCE(_turret);
	};
	PRIVATE LOCAL METHOD("getConnectedMonitors") {
		private _result = [];
		{
			_x params [["_mon", objNull], ["_instId", -1]];
			if (IS_OBJ(_mon) && {_instId > 0} && {(MON_GVAR(_mon, _instId, "CFM_connectedOperator", objNull)) isEqualTo _selfObj}) then {
				_result pushBack [_mon, _instId];
			};
		} forEach +(missionNamespace getVariable ["CFM_Monitors", []]);
		_result
	};
	//----------- Config set -----------
	PUBLIC LE GA METHOD("setPointParams") {
		params[["_turretIndex", -1], ["_params", []], ["_syncGlobal", false]];

		_turretIndex = TURRET_INDEX(_turretIndex);

		["setPointParams", [_params, _syncGlobal, true]] CALL_TURRET_INSTANCE(_turretIndex);
	};
	PUBLIC LE GA METHOD("setPPTurret") {
		params[["_turretIndex", -1], ["_ppParam", ""], ["_value", nil]];

		_turretIndex = TURRET_INDEX(_turretIndex);

		["setPPParam", [_ppParam, _NIL(_value)]] CALL_TURRET_INSTANCE(_turretIndex);
	};
	PUBLIC LE GA METHOD("setDefaultPointAlignment") {
		{
			["setPointParams", [_x, -1, false]] CALL_SELF;
		} forEach _turrets;
		true
	};
	PUBLIC LE GE GA METHOD("setOperatorSides") {
		params[["_sides", civilian], ["_global", false]];

		if !(_sides isEqualType []) then {
			_sides = [_sides];
		};
		_sides = _sides select {_x isEqualType west};

		if (_sides isEqualTo []) exitWith {false};

		_opSides = _sides;
		_selfObj setVariable ["CFM_opSides", _sides, _global];
		true
	};
	PUBLIC LE GA METHOD("setOperatorName") {
		params [["_operatorNameArg", ""]];
		if !(_operatorNameArg isEqualType "") exitWith {false};
		_operatorName = _operatorNameArg;
		_selfObj setVariable ["CFM_operatorName", _operatorName];
		{
			_x params ["_mon", "_instId"];
			if (MON_GVAR(_mon, _instId, "CFM_feedActive", false)) then {
				[[_mon, _instId], true, _selfObj, false] call CFM_fnc_setOperatorInfo;
			};
		} forEach (["getConnectedMonitors"] CALL_SELF);
		true
	};
	PUBLIC LE GA METHOD("setCanFeed") {
		params [["_canFeedArg", false]];
		if !(_canFeedArg isEqualType false) exitWith {false};
		_canFeed = _canFeedArg;
		_selfObj setVariable ["CFM_canFeed", _canFeed];
		if !(_canFeed) then {
			{
				_x params ["_mon", "_instId"];
				if (MON_GVAR(_mon, _instId, "CFM_feedActive", false)) then {
					[[_mon, _instId], false, false, false] call CFM_fnc_stopOperatorFeed;
				};
			} forEach (["getConnectedMonitors"] CALL_SELF);
		};
		true
	};
	PUBLIC LE GA METHOD("setCanSwitchNvg") {
		params [["_canSwitchNvgArg", false]];
		if !(_canSwitchNvgArg isEqualType false) exitWith {false};
		_canSwitchNvg = _canSwitchNvgArg;
		_selfObj setVariable ["CFM_canSwitchNvg", _canSwitchNvg];
		{
			_x params ["_mon", "_instId"];
			["setMonitorCanSwitchNvg", [_canSwitchNvg]] CALL_MON_INST(_mon, _instId);
		} forEach (["getConnectedMonitors"] CALL_SELF);
		true
	};
	PUBLIC LE GA METHOD("setCanSwitchTi") {
		params [["_canSwitchTiArg", false]];
		if !(_canSwitchTiArg isEqualType false) exitWith {false};
		_canSwitchTi = _canSwitchTiArg;
		_selfObj setVariable ["CFM_canSwitchTi", _canSwitchTi];
		{
			_x params ["_mon", "_instId"];
			["setMonitorCanSwitchTi", [_canSwitchTi]] CALL_MON_INST(_mon, _instId);
		} forEach (["getConnectedMonitors"] CALL_SELF);
		true
	};
	PUBLIC SE METHOD("setTurretParams") {
		// _this: TURRET.INIT params
		params [
			["_turretIndex", -1],
			["_turretObject", objNull]
		];
		// CAMERA OBJECT (proxy object which represents camera, used only for "camera destroyed" check)
		private _cameraObject = objNull;
		if (_turretObject isEqualType "") then {
			_turretObject = missionNamespace getVariable [_turretObject, objNull];
		};
		if (IS_OBJ(_turretObject) && {!(_turretObject getVariable ["OOP_isDummy", false])}) then {
			if (_isStaticCam || {_turretObject isNotEqualTo _selfObj}) then {
				_cameraObject = _turretObject;
			};
		};
		if (!_isStaticCam) then {
			// for non static cameras instance is always on operator, camera object is just proxy
			_turretObject = _selfObj;
		};
		if !(IS_OBJ(_turretObject)) then {
			_turretObject = _selfObj;
		} else {
			if (isServer && {_turretObject isNotEqualTo _selfObj}) then {
				if (_hasActiveTurretsObjects > 0) exitWith {};
				_hasActiveTurretsObjects = 0;
				_selfObj setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, true];
			};
		};
		if (IS_OBJ(_cameraObject)) then {
			[_selfObj, "CFM_cameraObjects", TURRET_INDEX(_turretIndex), _cameraObject, [true, [_selfObj, TURRET_INDEX(_turretIndex), _cameraObject], ["CFM_fnc_initCameraObjectEHs", true]]] call CFM_fnc_hashSetGlobal;
		} else {
			if ((TURRET_INDEX(_turretIndex)) in (_selfObj getVariable ["CFM_cameraObjects", createHashMap])) then {
				[_selfObj, "CFM_cameraObjects", TURRET_INDEX(_turretIndex), false] call CFM_fnc_deleteAtGlobal;
			};
		};
		if (!(_this isEqualType [])) then {_this = [_this]};
		_this = [_selfObj, _turretIndex] + (_this select [2, (count _this - 2) max 0]);
		private _turretInstanceId = TURRET_INSTANCE_ID(_turretIndex);
		if (_turretInstanceId <= 0) then {
			_turretInstance = ([_turretObject, _this] NEW_OBJINSTANCE_GLOBAL("Turret", true));
			_turretInstanceId = _turretInstance param [0, -1];
			if !(_turretInstanceId isEqualType 1) then {_turretInstanceId = -1};
		} else {
			["Init", _this] CALL_TURRET_INSTANCE(_turretIndex);
		};
		if (_turretInstanceId <= 0) exitWith {};
		[_selfObj, "CFM_turretsInstances", _turretIndex, [_turretInstanceId, _turretObject]] call CFM_fnc_hashSetGlobal;
	};
	//----------- Config get -----------
	PUBLIC GE GA METHOD("getPPTurret") {
		params[["_turretIndex", -1], ["_ppParam", ""], ["_def", nil]];

		_turretIndex = TURRET_INDEX(_turretIndex);

		["getPPParam", [_ppParam, _NIL(_def)], _NIL(_def)] CALL_TURRET_INSTANCE(_turretIndex);
	};
	PUBLIC LE GA METHOD("getOperatorName") {
		params[["_turret", -1]];

		private _curTurrIndex = TURRET_INDEX(_turret);
		private _turretName = IDX_TURRET_VAR(_curTurrIndex, _turretName, "");
		if (isNil "_turretName") exitWith {_operatorName};
		if (_turretName isEqualTo "") exitWith {_operatorName};
		_turretName
	};
	//----------- State control -----------
	PRIVATE GE METHOD("monitorConnected") {
		// should be executed globaly
		params[["_monitor", [objNull, -1]], ["_turret", [-1]], ["_caller", objNull], ["_reset", false]];

		(RESOLVE_MON(_monitor)) params ["_monObj", "_monInstId"];
		if (!(IS_OBJ(_monObj)) || {_monInstId < 1}) exitWith {};
		private _monPair = [_monObj, _monInstId];

		private _callerLocal = IS_OBJ(_caller) && {(local _caller)};

		_selfObj setVariable ["CFM_isFeeding", true];
		MON_SVAR(_monObj, _monInstId, "CFM_monitorCanSwitchNvg", _selfObj getVariable ["CFM_canSwitchNvg" I false]);
		MON_SVAR(_monObj, _monInstId, "CFM_monitorCanSwitchTi", _selfObj getVariable ["CFM_canSwitchTi" I false]);
		MON_SVAR(_monObj, _monInstId, "CFM_currentOpHasTurrets", _opHasTurrets);
		MON_SVAR(_monObj, _monInstId, "CFM_currentCameraType", _cameraType);
		MON_SVAR(_monObj, _monInstId, "CFM_currentOperatorIsDrone", _isDroneFeed);

		["TurretChanged", [_monPair, _turret, false, _callerLocal, _reset]] CALL_SELF;
	};
	PRIVATE GE LA METHOD("monitorConnectedLocalOperator") {
		params[["_monitor", [objNull, -1]], ["_turret", [-1]]];

		["addActiveOperator", [_operator]] CALL_CLASS("DbHandler");
		["TurretChangedLocalOperator", [_monitor, _turret]] CALL_SELF;
	};
	PRIVATE GE METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", [objNull, -1]], ["_turret", [-1]], ["_caller", objNull]];
	};
	PRIVATE GE LA METHOD("monitorDisconnectedLocalOperator") {
		params[["_monitor", [objNull, -1]], ["_turret", [-1]]];

		["removeMonitor", [_monitor, _turret]] CALL_SELF;
		if !([_selfObj] call CFM_fnc_checkIfOperatorFeedsToAnyMonitor) then {
			["removeActiveOperator", [_operator]] CALL_CLASS("DbHandler");
		};
	};
	PRIVATE GE METHOD("TurretChanged") {
		params["_monitor", ["_turret", [-1]], ["_global", true], ["_globalUpdOp", true], ["_reset", false]];

		["TurretChanged", [_monitor, _global, _globalUpdOp, _reset]] CALL_TURRET_INSTANCE(_turret);
	};
	PRIVATE GE LA METHOD("TurretChangedLocalOperator") {
		params["_monitor", ["_turret", [-1]]];

		["TurretChangedLocalOperator", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	PRIVATE GE METHOD("NextTurret") {
		params["_monitor", ["_currentTurret", [-1]]];

		private _curTurrIndex = TURRET_INDEX(_currentTurret);

		private _activeTurrs = _selfObj getVariable ["CFM_turrets", _turrets];
		private _turretsIndexes = _activeTurrs apply {TURRET_INDEX(_x)};
		private _turretsCount = count _turretsIndexes;

		if (_turretsCount <= 1) exitWith {_curTurrIndex};

		private _currIndex = _turretsIndexes findIf {_x isEqualTo _curTurrIndex};
		private _nextIndex = if (_currIndex == -1) then {0} else {_currIndex + 1};

		if ((_nextIndex + 1) > _turretsCount) then {
			_nextIndex = 0;
		};
		private _nextTurretIndex = _turretsIndexes select _nextIndex;

		private _done = ["feedTurretToMonitor", [_monitor, _nextTurretIndex]] CALL_SELF;

		if !(_done) exitWith {_curTurrIndex};

		_nextTurretIndex
	};
	PRIVATE GE METHOD("feedTurretToMonitor") {
		params["_monitor", ["_turret", [-1]]];

		(RESOLVE_MON(_monitor)) params ["_monObj", "_monInstId"];
		if (!(IS_OBJ(_monObj)) || {_monInstId < 1}) exitWith {false};
		private _monPair = [_monObj, _monInstId];

		private _turretIdx = TURRET_INDEX(_turret);

		private _activeTurrs = _selfObj getVariable ["CFM_turrets", _turrets];
		private _turretsIndexes = _activeTurrs apply {TURRET_INDEX(_x)};

		if !(_turretIdx in _turretsIndexes) exitWith {false};

		private _isVehSeat = MON_GVAR(_monObj, _monInstId, "CFM_isVehSeatTablet", false);
		private _texSel = MON_GVAR(_monObj, _monInstId, "CFM_textureSelection", NO_TEXTURE_SELECTION);
		private _seatKeys = MON_GVAR(_monObj, _monInstId, "CFM_seatKeys", []);
		private _isSingleSeatPip = _isVehSeat && {_texSel < 0} && {(count _seatKeys) <= 1};
		private _monIsLocal = (MON_GVAR(_monObj, _monInstId, "CFM_isLocal", false)) || _isSingleSeatPip;
		private _targets = MONITOR_VIEWERS_AND_SELF(_monObj, _monInstId, _monIsLocal);
		["TurretChanged", [_monPair, [_turretIdx], false, false], [_targets, false]] REMOTE_EXEC_OBJCLASS("Operator", _selfObj);
		if (_isSingleSeatPip && !isServer) then {
			["TurretChangedLocalOperator", [_monPair, [_turretIdx]], [2, false]] REMOTE_EXEC_OBJCLASS("Operator", _selfObj);
		};

		true
	};
	PRIVATE SE METHOD("removeActiveTurret") {
		params[["_turretIndex", -1]];

		private _targets = ACTIVE_VIEWERS_AND_SELF(false);
		[_selfObj, "CFM_activeTurretsObjects", _turretIndex, false, _targets, false] call CFM_fnc_deleteAtNet;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects - 1) max 0;
		_selfObj setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, _targets];
	};
	PRIVATE SE METHOD("addActiveTurret") {
		params[["_turretIndex", -1], ["_turretObject", objNull]];

		if (!(IS_OBJ(_turretObject)) || {_turretObject isEqualTo _selfObj}) exitWith {false};

		private _targets = ACTIVE_VIEWERS_AND_SELF(false);
		[_selfObj, "CFM_activeTurretsObjects", _turretIndex, _turretObject, false, _targets, false] call CFM_fnc_hashSetNet;
		_hasActiveTurretsObjects = _hasActiveTurretsObjects max 0;
		_hasActiveTurretsObjects = (_hasActiveTurretsObjects + 1) max 0;
		_selfObj setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, _targets];
		true
	};
	PRIVATE GE LA METHOD("addMonitor") {
		params[["_monitor", [objNull, -1]], ["_turret", [-1]]];

		["addMonitor", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	PRIVATE GE LA METHOD("removeMonitor") {
		params[["_monitor", [objNull, -1]], ["_turret", [-1]]];

		["removeMonitor", _monitor] CALL_TURRET_INSTANCE(_turret);
	};
	//----------- State set -----------
	PRIVATE LE GA METHOD("disableTurret") {
		params[["_turretIndex", -1]];
		_turretIndex = TURRET_INDEX(_turretIndex);

		private _disTurrs = _selfObj getVariable ["CFM_disabledTurrets", _disabledTurrets];
		if (_turretIndex in _disTurrs) exitWith {false};
		[_selfObj, "CFM_disabledTurrets", _turretIndex, true, false] call CFM_fnc_pushBack;
		_disabledTurrets = _selfObj getVariable ["CFM_disabledTurrets", []];

		// mark turret instance as disabled (instance is kept, not deleted)
		["setDisabled", [true, false]] CALL_TURRET_INSTANCE(_turretIndex);

		[_selfObj, "CFM_turrets", _turretIndex, false, false] call CFM_fnc_removeFromArray;
		_turrets = _selfObj getVariable ["CFM_turrets", []];
		_opHasTurrets = (count _turrets) > 1;
		_selfObj setVariable ["CFM_opHasTurrets", _opHasTurrets];

		// Handle monitors viewing this disabled turret
		["handleDisabledTurretViewers", [_turretIndex]] CALL_SELF;

		true
	};
	PRIVATE LE GA METHOD("enableTurret") {
		params[["_turretIndex", -1]];
		_turretIndex = TURRET_INDEX(_turretIndex);

		private _disTurrs = _selfObj getVariable ["CFM_disabledTurrets", _disabledTurrets];
		if !(_turretIndex in _disTurrs) exitWith {false};
		[_selfObj, "CFM_disabledTurrets", _turretIndex, false, false] call CFM_fnc_removeFromArray;
		_disabledTurrets = _selfObj getVariable ["CFM_disabledTurrets", []];

		["setDisabled", [false, false]] CALL_TURRET_INSTANCE(_turretIndex);

		[_selfObj, "CFM_turrets", _turretIndex, true, false] call CFM_fnc_pushBack;
		_turrets = _selfObj getVariable ["CFM_turrets", []];
		_opHasTurrets = (count _turrets) > 1;
		_selfObj setVariable ["CFM_opHasTurrets", _opHasTurrets];
		true
	};
	PRIVATE GE LA METHOD("moveCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2], ["_isContinuous", false, [false]]];

		["moveCamera", [_axisAngles, _isContinuous]] CALL_TURRET_INSTANCE(_turret);
	};
	PRIVATE GE LA METHOD("moveDroneCamera") {
		params[["_turret", -1], ["_axisAngles", [0,0], [[]], 2], ["_isContinuous", false, [false]]];

		["moveDroneCamera", [_axisAngles, _isContinuous]] CALL_TURRET_INSTANCE(_turret);
	};
	//----------- State get -----------
	PUBLIC GE GA METHOD("checkIfFeedsToAnyMonitor") {
		private _feeds = false;
		{
			_y params [["_turretInstanceId", -1], ["_turretObject", objNull]];
			private _monitorsOnTurret = TURRET_VAR(_monitorsOnTurret, []);
			if (count _monitorsOnTurret > 0) exitWith {
				_feeds = true;
				break;
			};
		} forEach _turretsInstances;
		_feeds
	};
	PUBLIC LE GA METHOD("isTurretDisabled") {
		params[["_turretIndex", -1]];
		(TURRET_INDEX(_turretIndex)) in (_selfObj getVariable ["CFM_disabledTurrets", _disabledTurrets])
	};
CLASS_END
