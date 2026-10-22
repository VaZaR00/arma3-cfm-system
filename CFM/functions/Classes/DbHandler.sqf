
#define NEXT_ID_FIND_TRIES 30
#define ITER_VAR_RMT_EXEC_DO_JIP false

SINGLETON_CLASS(DbHandler)

	METHOD("Init") {
		if !(isNil "CFM_inited") exitWith {};
		// local variables
		CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
		CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.08], [5, 0.04]];
		CFM_defaultZoomTable = createHashMapFromArray [[-1, createHashMapFromArray [[1, 1]]]];
		CFM_tiModesTableArray = [[0, 2], [1, 7], [6, 12]];
		CFM_tiModesTableArrayReverse = CFM_tiModesTableArray apply {[_x#1, _x#0]};
		CFM_tiModesTable = createHashMapFromArray CFM_tiModesTableArray;
		CFM_tiModesTableReverse = createHashMapFromArray CFM_tiModesTableArrayReverse;
		CFM_R2T_index = 0;
		CFM_MonitorsUIds = createHashMap;
		CFM_MonitorsR2Ts = createHashMap;
		CFM_DO_UPD_VARS = true;
		CFM_UPD_VARS_WAIT_TIME = 1;
		CFM_DB_HANDLER_VARS_TO_UPDATE = createHashMap;
		if (isServer) then {
			// global variables
			missionNamespace setVariable ["CFM_ActiveMonitors", []];
			missionNamespace setVariable ["CFM_ActiveMonitorViewers", [2], true];
			missionNamespace setVariable ["CFM_OperatorsIds", createHashMap];
		};
	};
	METHOD("setOperator") {
		// should be only server
		params[["_operator", objNull], ["_sides", []], ["_turrets", []], ["_hasTInNvg", [0, 0]], ["_name", ""], ["_params", []]];

		if (isNil "_operator") exitWith {80};

		private _mainArgs = [_sides, _turrets, _hasTInNvg, _name, _params];
		if (_operator isEqualType []) exitWith {
			_operator apply {
				if (isNil "_x") then {continue};
				if (_x isEqualType []) then {
					private _args = +_x;
					for "_i" from 1 to (count _mainArgs) do {
						private _val = _args#_i;
						if (isNil "_val") then {
							_args set [_i, (_mainArgs select (_i - 1))];
						};
					};
					_args call CFM_fnc_setOperator;
				} else {
					private _args = [_x] + _mainArgs;
					_args call CFM_fnc_setOperator;
				};
			};
		};

		private _opClass = _operator;
		private _opIsObj = IS_VALID_OP(_operator);
		private _opSet = if (_opIsObj) then {
			_opClass = _operator call CFM_fnc_getOperatorClass;
			[_operator, _mainArgs] NEW_OBJINSTANCE_GLOBAL("Operator", true);
		} else {true};

		if ((isNil "_opSet") || {!(_opSet isEqualTo true)}) exitWith {["_opSet", _opSet]};

		private _classType = [_opClass] call CFM_fnc_validClassType;

		if (_classType isEqualTo TYPE_HELM) then {
			["CFM_" + "addGoProHelmetClass", _opClass, true] call CFM_fnc_remoteEvent;
			CFM_checkGoPros = true;
		};
		if (_classType isEqualTo TYPE_UAV) then {
			CFM_checkUavsCams = true;
		};
		if (_classType isEqualTo TYPE_VEH) then {
			CFM_checkVehCams = true;
		};

		if !(IS_STR(_operator)) exitWith {100};

		["CFM_" + "addOperatorClass", [_opClass, _mainArgs], true] call CFM_fnc_remoteEvent;

		true
	};
	METHOD("setupMonitorDisplay") {
		params["_monitor"];

		if !(IS_OBJ(_monitor)) exitWith {};

		[_monitor] NEW_OBJINSTANCE("DisplayHandler");
	};
	METHOD("addToList") {
		params["_obj", ["_listName", ""], ["_unique", true]];
			
		[missionNamespace, _listName, _NIL(_obj), _unique, true] call CFM_fnc_pushBack;
	};
	METHOD("removeFromList") {
		params["_obj", ["_listName", ""], ["_pop", false]];
			
		[missionNamespace, _listName, _NIL(_obj), _pop, true] call CFM_fnc_removeFromArray;
	};
	METHOD("addToHashMap") {
		params["_key", ["_val", nil], ["_varName", ""]];
		
		[missionNamespace, _varName, _key, _NIL(_val), true] call CFM_fnc_hashSet;
	};
	METHOD("addCameraToPool") {
		params[["_cam", objNull]];
		if !(IS_OBJ(_cam)) exitWith {-1};
		["addToList", [_cam, "CFM_CameraPool"]] CALL_SELF;
	};
	METHOD("removeCameraFromPool") {
		params["_cam"];
		["removeFromList", [_cam, "CFM_CameraPool"]] CALL_SELF;
	};
	METHOD("addMonitor") {
		params["_monitor", ["_global", true]];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["CFM_" + "addMonitor", _monitor, _global] call CFM_fnc_remoteEvent;
	};
	METHOD("addOperator") {
		params["_operator", ["_global", true]];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["setOperatorId", [_operator]] CALL_SELF;
		["CFM_" + "addOperator", _operator, _global] call CFM_fnc_remoteEvent;
	};
	METHOD("removeOperator") {
		params["_operator", ["_global", false]];
		["CFM_" + "removeOperator", _operator, _global] call CFM_fnc_remoteEvent;
	};
	METHOD("setOperatorId") {
		private _res = -1;
		isNil {
			params["_operator"];
			if !(IS_OBJ(_operator)) exitWith {-1};
			private _id = _operator getVariable ["CFM_operatorId", -1];
			private _opsIdsHash = missionNamespace getVariable ["CFM_OperatorsIds", createHashMap];
			_res = if (_id isEqualTo -1) then {
				private _nextId = ["safeGenerateId", [_opsIdsHash]] CALL_SELF;
				if (_nextId < 0) exitWith {-1};
				_operator setVariable ["CFM_operatorId", _nextId, true];
				["CFM_" + "addOperatorId", [_nextId, _operator], true] call CFM_fnc_remoteEvent;
				_nextId
			} else {
				_id
			};
			if (_res < 0) then {
				format["DbHandler.setOperatorId: problem occured when trying to set id for object: '%1'. Id returned: '%2'. Current existing ids: '%3'", 
				_operator, _res, keys _opsIdsHash
				] WARN
			};
		};
		_res
	};
	METHOD("createMonitorUId") {
		private _uidStr = "";
		isNil {
			params["_monitor"];
			if !(IS_OBJ(_monitor)) exitWith {""};
			private _idsHash = missionNamespace getVariable ["CFM_MonitorsUIds", createHashMap];
			private _nextId = ["safeGenerateId", [_idsHash]] CALL_SELF;
			if (_nextId < 0) exitWith {
				format["DbHandler.createMonitorUId: problem occured when trying generate UI for monitor. Id returned: '%1'. Current existing ids: '%2'", 
				_nextId, keys _idsHash
				] WARN;
				""
			};
			_uidStr = UI_RENDER_ID_STR + str _nextId;
			_idsHash set [_nextId, _monitor];
			missionNamespace setVariable ["CFM_MonitorsUIds", _idsHash];
		};
		_uidStr
	};
	METHOD("createMonitorR2TId") {
		private _r2tStr = "";
		isNil {
			params["_monitor"];
			if !(IS_OBJ(_monitor)) exitWith {""};
			private _idsHash = missionNamespace getVariable ["CFM_MonitorsR2Ts", createHashMap];
			private _nextId = ["safeGenerateId", [_idsHash]] CALL_SELF;
			if (_nextId < 0) exitWith {
				format["DbHandler.createMonitorR2TId: problem occured when trying generate R2T id for monitor. Id returned: '%1'. Current existing ids: '%2'", 
				_nextId, keys _idsHash
				] WARN; 
				""
			};
			_r2tStr = RENDER_TARGET_STR + str _nextId;
			_idsHash set [_nextId, _monitor];
			missionNamespace setVariable ["CFM_MonitorsR2Ts", _idsHash];
		};
		_r2tStr
	};
	METHOD("addActiveMonitor") {
		params["_monitor"];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["addToList", [_monitor, "CFM_ActiveMonitors"]] CALL_SELF;
	};
	METHOD("removeActiveMonitor") {
		params["_monitor"];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["removeFromList", [_monitor, "CFM_ActiveMonitors"]] CALL_SELF;
	};
	METHOD("addActiveOperator") {
		params["_operator"];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["CFM_" + "addActiveOperator", _operator, 0] call CFM_fnc_remoteEvent;
	};
	METHOD("removeActiveOperator") {
		params["_operator"];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["CFM_" + "removeActiveOperator", _operator, 0] call CFM_fnc_remoteEvent;
	};
	METHOD("addActiveViewer") {
		params["_player"];
		if !(IS_OBJ(_player)) exitWith {-1};
		if (_player getVariable ["CFM_isActiveViewer", false]) exitWith {-2};
		private _ownerId = if (_player isEqualTo PLAYER_) then {clientOwner} else {owner _player};
		if ((_ownerId isEqualTo 0) && {isMultiplayer && !isServer}) exitWith {
			"ERROR addActiveViewer: CAN'T ADD REMOTE ACTIVE VIEWER ON NON SERVER MACHINE OR CLIENT SELF!" WARN;
			-1
		};
		_player setVariable ["CFM_isActiveViewer", true, true];
		["CFM_" + "addActiveViewer", _ownerId, 0] call CFM_fnc_remoteEvent;
		CFM_makeCamDataSync = true;
		["CFM_makeCamDataSync", [true, [clientOwner]]] call CFM_fnc_publicVariableServer;
	};
	METHOD("removeActiveViewer") {
		params["_player"];
		if !(IS_OBJ(_player)) exitWith {false};
		if !(_player getVariable ["CFM_isActiveViewer", false]) exitWith {false};
		private _ownerId = if (_player isEqualTo PLAYER_) then {clientOwner} else {owner _player};
		if ((_ownerId isEqualTo 0) && {isMultiplayer && !isServer}) exitWith {
			"ERROR removeActiveViewer: CAN'T REMOVE REMOTE ACTIVE VIEWER ON NON SERVER MACHINE OR CLIENT SELF!" WARN;
			false
		};
		_player setVariable ["CFM_isActiveViewer", false, true];
		["CFM_" + "removeActiveViewer", _ownerId, 0] call CFM_fnc_remoteEvent;
		true
	};
	METHOD("monitorAddActiveViewer") {
		params[["_monitor", objNull], ["_player", objNull]];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		if !(IS_OBJ(_player)) exitWith {-1};
		private _ownerId = if (_player isEqualTo PLAYER_) then {clientOwner} else {owner _player};
		if ((_ownerId isEqualTo 0) && {isMultiplayer && !isServer}) exitWith {
			"ERROR monitorAddActiveViewer: CAN'T ADD REMOTE ACTIVE VIEWER ON NON SERVER MACHINE OR CLIENT SELF!" WARN;
			-1
		};
		["CFM_" + "monitorAddActiveViewer", [_monitor, _ownerId], 0] call CFM_fnc_remoteEvent;
	};
	METHOD("monitorRemoveActiveViewer") {
		params[["_monitor", objNull], ["_player", objNull]];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		if !(IS_OBJ(_player)) exitWith {false};
		if !(_player getVariable ["CFM_isActiveViewer", false]) exitWith {false};
		private _ownerId = if (_player isEqualTo PLAYER_) then {clientOwner} else {owner _player};
		if ((_ownerId isEqualTo 0) && {isMultiplayer && !isServer}) exitWith {
			"ERROR monitorRemoveActiveViewer: CAN'T REMOVE REMOTE ACTIVE VIEWER ON NON SERVER MACHINE OR CLIENT SELF!" WARN;
			false
		};
		["CFM_" + "monitorRemoveActiveViewer", [_monitor, _ownerId], 0] call CFM_fnc_remoteEvent;
	};
	METHOD("nextR2Tindex") {
		private _current = missionNamespace getVariable ["CFM_R2T_index", 0];
		private _next = _current + 1;
		missionNamespace setVariable ["CFM_R2T_index", _next];
		_next
	};
	METHOD("safeGenerateId") {
		// safe id generation
		params["_idsHash"];
		private _ids = keys _idsHash;
		if (count _ids == 0) exitWith {0};
		_ids sort true;
		private _idRight = false;
		private _id = -1;
		private _tryCount = 0;
		private _lastId = _ids select -1;
		while {!_idRight && {_tryCount < NEXT_ID_FIND_TRIES}} do {
			_tryCount = _tryCount + 1;
			_id = _lastId + 1;
			if (_id in _ids) then {
				_lastId = _id;
			} else {
				_idRight = true;
			};
		};
		if (_id in _ids) exitWith {-1};
		_id
	};
	METHOD("updateActionPriority") {
		private _currentPriority = PLAYER_ getVariable ["CFM_currentActionsPriority", ACTIONS_PRIORITY];
		private _next = _currentPriority - 0.1;
		if (_next < 10) then {
			_next = ACTIONS_PRIORITY + ACTIONS_PRIORITY;
		};
		PLAYER_ setVariable ["CFM_currentActionsPriority", _next];
		_next
	};
	METHOD("createDummyForStaticCam") {
		// execute only on server, because of JIP sync and to avoid creating multiple dummies on different machines
		private _dummyObj = createVehicle [DUMMY_CLASSNAME, [0,0,0]];
		["addDummy", [_dummyObj]] CALL_SELF;
		_dummyObj
	};
	METHOD("addDummy") {
		params["_dummyObj"];
		["addToList", [_dummyObj, "CFM_DummyObjs"]] CALL_SELF;
	};
CLASS_END