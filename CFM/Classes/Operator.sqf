CLASS(Operator)

	SET_SELF_VAR(_operator);

	OBJ_VARIABLE(_canSwitchTi, false);
	OBJ_VARIABLE(_canSwitchNvg, false);
	OBJ_VARIABLE(_opHasTurrets, false);
	OBJ_VARIABLE(_turrets, [DRIVER_TURRET_PATH]);
	OBJ_VARIABLE(_doCheckTurretLocality, false);
	OBJ_VARIABLE(_cameraType, "");
	OBJ_VARIABLE(_hasGoPro, false);
	OBJ_VARIABLE(_canFeed, false);
	OBJ_VARIABLE(_classType, "");
	OBJ_VARIABLE(_camerasSet, createHashMap);
	OBJ_VARIABLE(_tiTable, createHashMap);
	OBJ_VARIABLE(_nvgTable, createHashMap);
	OBJ_VARIABLE(_operatorSet, false);

	METHODS

	METHOD("init") {
		// should be executed globaly
		params[["_operator", "_self"], ["_class", ""], ["_hasTInNvg", [0, 0]], ["_turrets", [DRIVER_TURRET_PATH]], ["_params", []]];

		if !(IS_OBJ(_operator)) exitWith {};

		if !(IS_STR(_type)) then {
			_type = "";
		};

		if (_classType isEqualTo "") then {
			_classType =  [_operator] call CFM_fnc_validClassType;
		};
		if !(_classType in VALID_CLASS_TYPES) exitWith {"Init Operator: Invalid class type passed"};

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
		_operator setVariable ["CFM_tiTable", _tiTable];
		_operator setVariable ["CFM_nvgTable", _nvgTable];
		_operator setVariable ["CFM_canSwitchTi", _canSwitchTi];
		_operator setVariable ["CFM_canSwitchNvg", _canSwitchNvg];
		
		_operator setVariable ["CFM_operatorSet", true];

		private _clssSetup = missionNamespace getVariable ["CFM_classesSetup", createHashMap];

		_operator setVariable ["CFM_canSwitchTi", _ti];
		_operator setVariable ["CFM_canSwitchNvg", _nvg];
		if ((count (crew _operator) > 1) && {!((gunner _operator) isEqualTo objNull)}) then {
			_operator setVariable ["CFM_opHasTurrets", true]; 
			_turrets = [DRIVER_TURRET_PATH, GUNNER_TURRET_PATH];
			_operator setVariable ["CFM_turrets", _turrets]; 
		};
		_operator setVariable ["CFM_doCheckTurretLocality", [_operator] call CFM_fnc_doCheckTurretLocality]; 

		_type = if (_type isEqualTo "") then {
			[_operator] call CFM_fnc_cameraType;
		} else {
			_type
		};

		_operator setVariable ["CFM_cameraType", _type];
		_operator setVariable ["CFM_isCameraSet", true];

		["addOperator", [_operator]] CALL_CLASS(DbHandler);

		switch (_type) do {
			case GOPRO: {
				_operator setVariable ["CFM_hasGoPro", true];
			};
			case DRONETYPE: {
				_operator setVariable ["CFM_canFeed", true];
			};
			default {};
		};
	};
	METHOD("initMonitor") {
		// should be executed globaly
		params[["_monitor", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {};

		_monitor setVariable ["CFM_canSwitchNvg", _canSwitchNvg];
		_monitor setVariable ["CFM_canSwitchTi", _canSwitchTi];
		_monitor setVariable ["CFM_opHasTurrets", _opHasTurrets];
		_monitor setVariable ["CFM_cameraType", _cameraType];
		_monitor setVariable ["CFM_tiTable", _tiTable];
		_monitor setVariable ["CFM_nvgTable", _nvgTable];
	};
	METHOD("newCamera") {
		params[["_monitor", objNull, [objNull]], ["_turret", DRIVER_TURRET_PATH]];
		
		private _camera = [] call CFM_fnc_createCamera;

		[_camera, _self, _monitor, _turret] NEW_OBJINSTANCE("Camera");

		_camera
	};
	METHOD("addCamera") {
		params[["_cam", objNull, [objNull]], ["_monitor", objNull, [objNull]], ["_turretIndex", -1, [1]]];
		
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		_turrCameras pushBackUnique [_monitor, _cam];
		_camerasSet set [_turretIndex, _turrCameras];
		_self setVariable ["CFM_camerasSet", _camerasSet];

		_camerasSet
	};
	METHOD("getCamera") {
		params[["_monitor", objNull], ["_turret", ""], ["_createNew", true]];

		if !(IS_OBJ(_monitor)) exitWith {objNull};
		if !(_turret isEqualType []) then {
			_turret = [_turret];
		};
		if !(_turret in _turrets) exitWith {objNull};
		private _turretIndex = _turret#0;
		if !(_turretIndex isEqualType 1) exitWith {objNull};

		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		private _cameras = (_turrCameras select {if ((_x isEqualType []) && {(count _x > 0)}) then {((_x#0) isEqualTo _monitor)} else {false}});

		if (_cameras isEqualTo []) exitWith {
			if !(_createNew) exitWith {objNull};
			private _cam = ["newCamera", [_monitor, _turret], _self, objNull] CALL_OBJCLASS(_self);
			if !(IS_OBJ(_cam)) exitWith {objNull};
			["addCamera", [_cam, _monitor, _turretIndex], _self, []] CALL_OBJCLASS(_self);
			_cam
		};

		_cameras#0
	};
	METHOD("getRenderTarget") {
		params[["_monitor", objNull], ["_turret", DRIVER_TURRET_PATH]];

		if !(IS_OBJ(_monitor)) exitWith {""};

		private _camera = ["getCamera", [_turret], _self, objNull] CALL_OBJCLASS(_self);

		if !(IS_OBJ(_camera)) exitWith {""};

		["getRenderTarget", [], _camera, ""] CALL_OBJCLASS(_camera);
	};
	METHOD("setZoom") {
		params["_monitor", ["_turret", DRIVER_TURRET_PATH], ["_newzoom", 1]];
		
		private _camera = ["getCamera", [_monitor, _turret, false], _self, objNull] CALL_OBJCLASS(_self);

		if !(IS_OBJ(_camera)) exitWith {};

		_camera setVariable ["CFM_zoom", _newzoom, true];

		_newzoom
	};
CLASS_END