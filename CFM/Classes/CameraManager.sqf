CLASS(CameraManager)

	METHODS

	METHOD("CreateCamera") {
		params[["_initOperator", objNull], ["_initMonitor", objNull], ["_turret", DRIVER_TURRET_PATH]];

		if !(IS_OBJ(_initOperator)) exitWith {objNull};
		if !(IS_OBJ(_initMonitor)) exitWith {objNull};

		_operator = _initOperator;
		_currentMonitor = _initMonitor;

		_renderTarget = [] call CFM_fnc_getNextRenderTarget;


		_self cameraEffect ["internal", "back", _renderTarget];

		_self setVariable ["CFM_operator", _operator];
		_self setVariable ["CFM_currentMonitor", _currentMonitor];
		_self setVariable ["CFM_turret", _turret];
		_self setVariable ["CFM_zoom", 1];
		_self setVariable ["CFM_renderTarget", _renderTarget]; 
		_a = [_self getVariable ["CFM_operator", "NIL"], _self getVariable ["CFM_renderTarget", "NIL"], _self getVariable ["CFM_currentMonitor", "NIL"]];

		["addCameraToPool", [_self]] CALL_OBJCLASS(_self);
	};
	METHOD("addCameraToPool") {
		params[["_cam", objNull]];
		["addCameraToPool", [_cam]] CALL_CLASS("DbHandler");
	};
	METHOD("removeCameraFromPool") {
		params[["_cam", objNull]];
		["removeCameraFromPool", [_cam]] CALL_CLASS("DbHandler");
	};
	METHOD("destroyCamera") {
		params[["_cam", objNull]];
		if !(IS_OBJ(_cam)) exitWith {false};
		["removeCameraFromPool", [_cam]] CALL_CLASS(_self);
		camDestroy _cam;
		true
	};
	METHOD("getRenderTarget") {
		params[["_monitor", objNull]];
		private _renderTarget = _self getVariable ["CFM_renderTarget", _renderTarget];
		["Camera getRenderTarget", _self, _renderTarget, _monitor] RLOG;
		if (RENDER_TARGET_STR in _renderTarget) then {
			_monitor setVariable ["CFM_currentFeedCam", _self];
			_renderTarget
		} else {
			""
		};
	};
	METHOD("addCameraToOperator") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]], ["_monitor", objNull, [objNull]], ["_turretIndex", -1, [1]]];
		
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		_turrCameras pushBackUnique [_monitor, _cam];
		_camerasSet set [_turretIndex, _turrCameras];
		_operator setVariable ["CFM_camerasSet", _camerasSet];

		_camerasSet
	};
	METHOD("getOperatorCamera") {
		params[["_operator", objNull], ["_monitor", objNull], ["_turret", ""], ["_createNew", true]];

		if !(IS_OBJ(_operator)) exitWith {objNull};
		if !(IS_OBJ(_monitor)) exitWith {objNull};
		if !(_turret isEqualType []) then {
			_turret = [_turret];
		};
		private _turrets = _operator getVariable ["CFM_turrets", []];
		if !(_turret in _turrets) exitWith {objNull};
		private _turretIndex = _turret#0;
		if !(_turretIndex isEqualType 1) exitWith {objNull};

		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		private _cameras = (_turrCameras select {if ((_x isEqualType []) && {(count _x > 0)}) then {((_x#0) isEqualTo _monitor)} else {false}});

		if (_cameras isEqualTo []) exitWith {
			if !(_createNew) exitWith {objNull};
			private _cam = ["CreateCamera", [_operator, _monitor, _turret], _self, objNull] CALL_CLASS(_self);
			if !(IS_OBJ(_cam)) exitWith {objNull};
			["addCameraToOperator", [_operator, _cam, _monitor, _turretIndex], _self, []] CALL_CLASS(_self);
			_cam
		};

		_cameras#0
	};
CLASS_END