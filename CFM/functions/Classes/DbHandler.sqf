#define NEXT_OPERATOR_ID_FIND_TRIES 30

CLASS(DbHandler)

	METHODS

	METHOD("Init") {
		if !(isNil "CFM_inited") exitWith {};
		CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
		CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.08], [5, 0.04]];
		CFM_defaultZoomTable = createHashMapFromArray [[-1, createHashMapFromArray [[1, 1]]]];
		CFM_tiModesTableArray = [[0, 2], [1, 7], [6, 12]];
		CFM_tiModesTableArrayReverse = CFM_tiModesTableArray apply {[_x#1, _x#0]};
		CFM_tiModesTable = createHashMapFromArray CFM_tiModesTableArray;
		CFM_tiModesTableReverse = createHashMapFromArray CFM_tiModesTableArrayReverse;
		CFM_R2T_index = 0;
		if (isServer) then {
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
			["addToList", [_opClass, "CFM_goProHelmets", true]] CALL_CLASS(_self);
			CFM_checkGoPros = true;
		};
		if (_classType isEqualTo TYPE_UAV) then {
			CFM_checkUavsCams = true;
		};
		if (_classType isEqualTo TYPE_VEH) then {
			CFM_checkVehCams = true;
		};

		if !(IS_STR(_operator)) exitWith {100};

		["addToHashMap", [_opClass, _mainArgs, "CFM_OperatorClasses", true]] CALL_CLASS(_self);

		true
	};
	METHOD("addToList") {
		params["_obj", ["_listName", ""], ["_global", false], ["_unique", true], ["_viaPubVar", false]];
		
		if (isNil "_obj") exitWith {-1};
		if (_listName isEqualTo "") exitWith {-1};

		private _list = +(missionNamespace getVariable [_listName, []]);
		private _i = -1;
		if !(_list isEqualType []) then {
			_list = +[_obj];
			_i = 0;
		} else {
			_i = if (_unique) then {
				_list pushBackUnique _obj;
			} else {
				_list pushBack _obj;
			};
		};
		if (_global && _viaPubVar) then {
			missionNamespace setVariable [_listName, _list];
			publicVariable _listName;
			call (missionNamespace getVariable [_listName + "_PublicEH", {}]);
		} else {
			missionNamespace setVariable [_listName, _list, _global];
		};
		_i
	};
	METHOD("removeFromList") {
		params["_obj", ["_listName", ""], ["_global", false]];
		
		if (isNil "_obj") exitWith {false};
		if (_listName isEqualTo "") exitWith {false};

		private _list = missionNamespace getVariable [_listName, []];
		private _index = _list findIf {_x isEqualTo _obj};
		if (_index != -1) then {
			_list deleteAt _index;
			missionNamespace setVariable [_listName, _list, _global];
			true
		} else {false};
	};
	METHOD("addToHashMap") {
		params["_key", ["_val", nil], ["_varName", ""], ["_global", false], ["_unique", true]];
		
		if (isNil "_key") exitWith {false};
		if (_varName isEqualTo "") exitWith {false};

		private _hash = (missionNamespace getVariable [_varName, createHashMap]);
		if !(_hash isEqualType createHashMap) then {
			_hash = createHashMap;
		} else {
			_hash set [_key, _val];
		};
		missionNamespace setVariable [_varName, _hash, _global];
		true
	};
	METHOD("addCameraToPool") {
		params[["_cam", objNull]];
		if !(IS_OBJ(_cam)) exitWith {-1};
		["addToList", [_cam, "CFM_CameraPool"]] CALL_CLASS(_self);
	};
	METHOD("removeCameraFromPool") {
		params["_cam"];
		["removeFromList", [_cam, "CFM_CameraPool"]] CALL_CLASS(_self);
	};
	METHOD("addMonitor") {
		params["_monitor", ["_global", true]];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["addToList", [_monitor, "CFM_Monitors", _global]] CALL_CLASS(_self);
	};
	METHOD("addOperator") {
		params["_operator", ["_global", true]];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["setOperatorId", [_operator]] CALL_CLASS(_self);
		["addToList", [_operator, "CFM_Operators", _global]] CALL_CLASS(_self);
	};
	METHOD("removeOperator") {
		params["_operator", ["_global", false]];
		["removeFromList", [_operator, "CFM_Operators"]] CALL_CLASS(_self);
	};
	METHOD("setOperatorId") {
		params["_operator"];
		if !(IS_OBJ(_operator)) exitWith {-1};
		private _id = _operator getVariable ["CFM_operatorId", -1];
		private _opsIdsHash = missionNamespace getVariable ["CFM_OperatorsIds", createHashMap];
		private _res = if (_id isEqualTo -1) then {
			private _nextId = ["nextOperatorId"] CALL_CLASS(_self);
			if (_nextId < 0) exitWith {-1};
			_opsIdsHash set [_nextId, _operator];
			_operator setVariable ["CFM_operatorId", _nextId, true];
			missionNamespace setVariable ["CFM_OperatorsIds", _opsIdsHash, true];
			_nextId
		} else {
			_id
		};
		if (_res < 0) then {
			format["DbHandler.setOperatorId: problem occured when trying to set id for object: '%1'. Id returned: '%2'. Current existing ids: '%3'", 
			_operator, _res, keys _opsIdsHash
			] WARN
		};
		_res
	};
	METHOD("nextOperatorId") {
		// safe id generation
		private _opsIdsHash = missionNamespace getVariable ["CFM_OperatorsIds", createHashMap];
		if !(_opsIdsHash isEqualType createHashMap) then {
			_opsIdsHash = createHashMap;
			missionNamespace setVariable ["CFM_OperatorsIds", _opsIdsHash];
		};
		private _opsIds = keys _opsIdsHash;
		if (count _opsIds == 0) exitWith {0};
		_opsIds sort true;
		private _idRight = false;
		private _id = -1;
		private _tryCount = 0;
		private _lastId = _opsIds select -1;
		while {!_idRight && {_tryCount < NEXT_OPERATOR_ID_FIND_TRIES}} do {
			_tryCount = _tryCount + 1;
			_id = _lastId + 1;
			if (_id in _opsIds) then {
				_lastId = _id;
			} else {
				_idRight = true;
			};
		};
		if (_id in _opsIds) exitWith {-1};
		_id
	};
	METHOD("addActiveMonitor") {
		params["_monitor"];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["addToList", [_monitor, "CFM_ActiveMonitors"]] CALL_CLASS(_self);
	};
	METHOD("removeActiveMonitor") {
		params["_monitor"];
		if !(IS_OBJ(_monitor)) exitWith {-1};
		["removeFromList", [_monitor, "CFM_ActiveMonitors"]] CALL_CLASS(_self);
	};
	METHOD("addActiveOperator") {
		params["_operator"];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["addToList", [_operator, "CFM_ActiveOperators", true, true, true]] CALL_CLASS(_self);
		if !(isMultiplayer) then {
			CFM_LocalActiveOperators = CFM_ActiveOperators;
		};
	};
	METHOD("removeActiveOperator") {
		params["_operator"];
		if !(IS_OBJ(_operator)) exitWith {-1};
		["removeFromList", [_operator, "CFM_ActiveOperators", true, true, true]] CALL_CLASS(_self);
		if !(isMultiplayer) then {
			CFM_LocalActiveOperators = CFM_ActiveOperators;
		};
	};
	METHOD("addActiveViewer") {
		params["_player"];
		if !(IS_OBJ(_player)) exitWith {-1};
		if (_player getVariable ["CFM_isActiveViewer", false]) exitWith {-2};
		private _ownerId = if (_player isEqualTo PLAYER_) then {clientOwner} else {owner _player};
		if ((_ownerId isEqualTo 0) && {isMultiplayer && !isServer}) exitWith {
			"ERROR addActiveViewer: CAN'T ADD REMOTE ACTIVE VIEWER ON NON SERVER MACHINE!" WARN;
			-1
		};
		["addToList", [_ownerId, "CFM_ActiveMonitorViewers", true]] CALL_CLASS(_self);
		_player setVariable ["CFM_isActiveViewer", true, true];
		CFM_makeCamDataSync = true;
		publicVariableServer "CFM_makeCamDataSync";
	};
	METHOD("deepCopy") {
		params [["_copyFrom", objNull], ["_copyTo", objNull], ["_classname", ""], ["_doInit", false], ["_global", false]];
		if !(IS_OBJ(_copyFrom)) exitWith {false};
		if !(IS_OBJ(_copyTo)) exitWith {false};
		if !(IS_STR(_classname)) exitWith {false};
		if (_classname isEqualTo "") exitWith {false};

		private _ooAllVars = _copyFrom getVariable ["CFM_ooAllVars", createHashMap];
		_ooAllVars apply {
			private _name = _x;
			private _def = _y;
			private _val = _copyFrom getVariable [_name, _def];
			_copyTo setVariable [_name, _val, _global];
		};
		if (_doInit) then {
			[_copyTo] NEW_OBJINSTANCE(_classname)
		} else {
			private _classFunc = (missionNamespace getVariable [_classname, {}]);
			if !(_classFunc isEqualType {}) exitWith {};
			if (_classFunc isEqualTo {}) exitWith {};
			SET_THIS_OBJINSTANCE(_classname, _copyTo, _classFunc) \
		};
		true
	};
	METHOD("nextR2Tindex") {
		private _current = missionNamespace getVariable ["CFM_R2T_index", 0];
		private _next = _current + 1;
		missionNamespace setVariable ["CFM_R2T_index", _next];
		_next
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
		["addDummy", [_dummyObj]] CALL_CLASS(_self);
		_dummyObj
	};
	METHOD("addDummy") {
		params["_dummyObj"];
		["addToList", [_dummyObj, "CFM_DummyObjs"]] CALL_CLASS(_self);
	};
CLASS_END