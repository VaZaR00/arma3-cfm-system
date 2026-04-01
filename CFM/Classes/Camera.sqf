CLASS(Camera)

	SET_SELF_VAR(_camera);

	OBJ_VARIABLE(_operator, objNull);
	OBJ_VARIABLE(_currentMonitor, objNull);
	OBJ_VARIABLE(_zoom, 1);
	OBJ_VARIABLE(_turret, DRIVER_TURRET_PATH);

	METHODS

	METHOD("init") {
		params[["_camera", _self], ["_initOperator", objNull], ["_initMonitor", objNull], ["_turret", DRIVER_TURRET_PATH]];

		if !(IS_OBJ(_initOperator)) exitWith {
			[_self] call CFM_fnc_destroyCamera;
		};
		if !(IS_OBJ(_initMonitor)) exitWith {
			[_self] call CFM_fnc_destroyCamera;
		};

		_operator = _initOperator;
		_currentMonitor = _initMonitor;

		_self setVariable ["CFM_operator", _operator];
		_self setVariable ["CFM_currentMonitor", _currentMonitor];
		_self setVariable ["CFM_turret", _turret];
		_self setVariable ["CFM_zoom", 1];

		["addCameraToPool", [_self]] CALL_OBJCLASS(_self);
	};
	METHOD("addCameraToPool") {
		params[["_cam", _self]];
		["addCameraToPool", [_cam]] CALL_CLASS(DbHandler);
	};
	METHOD("removeCameraFromPool") {
		params[["_cam", _self]];
		["removeCameraFromPool", [_cam]] CALL_CLASS(DbHandler);
	};
	METHOD("destroyCamera") {
		params[["_cam", _self]];
		["removeCameraFromPool", [_self]] CALL_OBJCLASS(_self);
		camDestroy _cam;
	};
CLASS_END