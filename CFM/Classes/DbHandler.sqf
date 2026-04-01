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
	METHOD("addCameraToPool") {
		params["_cam"];
		["addToList", [_cam, "CFM_CameraPool"]] CALL_CLASS(_self);
	};
	METHOD("addMonitor") {
		params["_monitor", ["_global", true]];
		["addToList", [_monitor, "CFM_Monitors", _global]] CALL_CLASS(_self);
	};
	METHOD("addOperator") {
		params["_operator"];
		["addToList", [_operator, "CFM_Operators"]] CALL_CLASS(_self);
	};
CLASS_END