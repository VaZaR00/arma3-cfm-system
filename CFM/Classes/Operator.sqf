OBJCLASS(Operator)

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
	OBJ_VARIABLE(_monitorsSet, createHashMap);
	OBJ_VARIABLE(_tiTable, createHashMap);
	OBJ_VARIABLE(_nvgTable, createHashMap);
	OBJ_VARIABLE(_operatorSet, false);
	OBJ_VARIABLE(_isFeeding, false);
	OBJ_VARIABLE(_isDroneFeed, false);	
	OBJ_VARIABLE(_staticCamOffset, NULL_VECTOR);	

	METHODS

	METHOD("Init") {
		// should be executed globaly
		params[["_type", ""], ["_hasTInNvg", [0, 0]], ["_turrets", [DRIVER_TURRET_PATH]], ["_params", []]];

		if !(IS_OBJ(_operator)) exitWith {};

		if !(IS_STR(_type)) then {
			_type = "";
		};

		if (_classType isEqualTo "") then {
			_classType =  [typeOf _operator] call CFM_fnc_validClassType;
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
		};
		_operator setVariable ["CFM_turrets", _turrets]; 
		_operator setVariable ["CFM_doCheckTurretLocality", [_operator] call CFM_fnc_doCheckTurretLocality]; 

		_type = if (_type isEqualTo "") then {
			[_operator] call CFM_fnc_cameraType;
		} else {
			_type
		};

		_operator setVariable ["CFM_cameraType", _type];
		_operator setVariable ["CFM_isCameraSet", true];

		["addOperator", [_operator]] CALL_CLASS("DbHandler");

		switch (_type) do {
			case GOPRO: {
				_operator setVariable ["CFM_hasGoPro", true];
			};
			case DRONETYPE: {
				_operator setVariable ["CFM_canFeed", true];
				_operator setVariable ["CFM_isDroneFeed", true];
			};
			case TYPE_VEH: {
				_operator setVariable ["CFM_canFeed", true];
				_operator setVariable ["CFM_isVehFeed", true];
			};
			default {};
		};
	};
	METHOD("monitorConnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {};

		if (player isEqualTo _caller) then {
			["addMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		};

		_self setVariable ["CFM_isFeeding", true];
		_monitor setVariable ["CFM_monitorCanSwitchNvg", _canSwitchNvg];
		_monitor setVariable ["CFM_monitorCanSwitchTi", _canSwitchTi];
		_monitor setVariable ["CFM_currentOpHasTurrets", _opHasTurrets];
		_monitor setVariable ["CFM_currentCameraType", _currentCameraType];
		_monitor setVariable ["CFM_currentTiTable", _tiTable];
		_monitor setVariable ["CFM_currentNvgTable", _nvgTable];
		_monitor setVariable ["CFM_currentOperatorIsDrone", _isDroneFeed];

		private _camParams = [_self, _cameraType] call CFM_fnc_defineCamTypeParams;
		_camParams params [
			["_cameraPosFunc", {}], 
			["_zoomMax", 1], 
			["_zoomTable", createHashMap],
			["_staticCamOffset", NULL_VECTOR],
			["_doCheckTurretLocality", _doCheckTurretLocality]
		];

		if (count _staticCamOffset != 3) then {
			_staticCamOffset = NULL_VECTOR;
		};

		_self setVariable ["CFM_staticCamOffset", _staticCamOffset];
		_monitor setVariable ["CFM_zoomMax", _zoomMax];
		_monitor setVariable ["CFM_cameraPosFunc", _cameraPosFunc];
		_monitor setVariable ["CFM_zoomTable", _zoomTable];
		_monitor setVariable ["CFM_turretLocal", _doCheckTurretLocality];
	};
	METHOD("monitorDisconnected") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]], ["_caller", objNull]];

		if (player isEqualTo _caller) then {
			["removeMonitor", [_monitor, _turret]] CALL_OBJCLASS("Operator", _self);
		};
	};
	METHOD("addMonitor") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]]];

		if !(IS_OBJ(_monitor)) exitWith {-1};

		private _turretIndex = _turret#0;
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		private _i = _monitorsOnTurret pushBackUnique _monitor;
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		_i
	};
	METHOD("removeMonitor") {
		// should be executed globaly
		params[["_monitor", objNull], ["_turret", [-1]]];

		private _turretIndex = _turret#0;
		private _monitorsOnTurret = _monitorsSet getOrDefault [_turretIndex, []];
		_monitorsOnTurret = _monitorsOnTurret - [_monitor];
		_monitorsSet set [_turretIndex, _monitorsOnTurret];
		_self setVariable ["CFM_monitorsSet", _monitorsSet, true];
		true
	};
CLASS_END