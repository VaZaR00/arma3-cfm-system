CLASS(DbHandler)

	METHODS

	METHOD("init") {
		CFM_goPro_zoomTable = createHashMapFromArray [[2, 0.25]];
		CFM_drone_zoomTable = createHashMapFromArray [[2, 0.5], [3, 0.2], [4, 0.09], [5, 0.07]];
		CFM_tiModesTable = createHashMapFromArray [[0, 2], [1, 7], [6, 12]];
		CFM_classesSetup = createHashMap;
		CFM_CameraPool = [];
		CFM_Monitors = [];
		CFM_Operators = [];
		// CFM_OperatorClasses = [];
	};
	METHOD("setOperator") {
		// should be executed globaly
		params["_operator", ["_type", ""], ["_hasTInNvg", [0, 0]], ["_params", []]];

		if (_operator isEqualType []) exitWith {
			_operator apply {
				[_x, _type, _hasTInNvg, _params] call CFM_fnc_setOperator;
			};
		};

		if (IS_OBJ(_operator)) exitWith {
			private _class = typeOf _operator;
			[_operator] NEW_OBJINSTANCE("Operator");
		};

		if !(IS_STR(_operator)) exitWith {false};

		if (_classType isEqualTo TYPE_HELM) then {
			["addToList", [_operator, "CFM_goProHelmets"]] CALL_CLASS(_self);
			CFM_checkGoPros = true;
		};
		if (_classType isEqualTo TYPE_UAV) then {
			CFM_checkUavsCams = true;
		};
		if (_classType isEqualTo TYPE_VEH) then {
			CFM_checkVehCams = true;
		};

		// ["addToHashMap", [[_operator, []], "CFM_OperatorClasses"]] CALL_CLASS(_self);

		true
	};
	METHOD("addToList") {
		params["_obj", ["_listName", ""], ["_global", false], ["_unique", true]];
		
		if (isNil "_obj") exitWith {-1};
		if (_listName isEqualTo "") exitWith {-1};

		private _list = missionNamespace getVariable [_listName, []];
		private _i = if (_unique) then {
			_list pushBackUnique _obj;
		} else {
			_list pushBack _obj;
		};
		missionNamespace setVariable [_listName, _list, _global];
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
			_i
		} else {false};
	};
	METHOD("addToHashMap") {-1};
	METHOD("addCameraToPool") {
		params["_cam"];
		["addToList", [_cam, "CFM_CameraPool"]] CALL_CLASS(_self);
	};
	METHOD("removeCameraFromPool") {
		params["_cam"];
		["removeFromList", [_cam, "CFM_CameraPool"]] CALL_CLASS(_self);
	};
	METHOD("addMonitor") {
		params["_monitor", ["_global", true]];
		["addToList", [_monitor, "CFM_Monitors", _global]] CALL_CLASS(_self);
	};
	METHOD("addOperator") {
		params["_operator"];
		["addToList", [_operator, "CFM_Operators"]] CALL_CLASS(_self);
	};
	METHOD("deepCopy") {
		params [["_copyFrom", objNull], ["_copyTo", objNull], ["_doInit", false], ["_global", false]];
		if !(IS_OBJ(_copyFrom)) exitWith {false};
		if !(IS_OBJ(_copyTo)) exitWith {false};

		private _ooAllVars = _copyFrom getVariable ["CFM_ooAllVars", createHashMap];
		private _classname = _copyFrom getVariable [format["OOP_%1_class", SPREFX], ""];
		_ooAllVars apply {
			private _name = _x;
			private _def = _y;
			private _val = _copyFrom getVariable [_name, _def];
			_copyTo setVariable [_name, _val, _global];
		};
		if (_doInit) then {
			[_copyTo] NEW_OBJINSTANCE(_classname)
		} else {
			private _classFunc = (missionNamespace getVariable [_classname, {}])
			if !(_classFunc isEqualType {}) exitWith {};
			if (_classFunc isEqualTo {}) exitWith {};
			_copyTo setVariable [format["OOP_%1_thisInstance", SPREFX], _classFunc, _global];
			_copyTo setVariable [format["OOP_%1_class", SPREFX], _classname, _global];
		};
		true
	};
CLASS_END