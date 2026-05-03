
CLASS(CameraManager)

	/*
		Operator's camerasSet: [monitor, camera, params:[operator, turret, zoom, turretLocal]]
	*/

	METHODS

	CLASS_METHOD("Init") {
	};
	CLASS_METHOD("CreateCamera") {
		params[["_monitor", objNull], ["_renderTarget", ""]];
		
		if !(IS_OBJ(_monitor)) exitWith {[objNull, ""]};

		private _cam = [] call CFM_fnc_createCamera;
		
		if !(IS_OBJ(_cam)) exitWith {[objNull, ""]};

		_cam cameraEffect ["internal", "back", _renderTarget];
		
		["setMonitorCamera", [_self]] CALL_CLASS(_self);
		["addCameraToPool", [_self]] CALL_CLASS(_self);

		_cam
	};
	CLASS_METHOD("addCameraToPool") {
		params[["_cam", objNull]];
		["addCameraToPool", [_cam]] CALL_CLASS("DbHandler");
	};
	CLASS_METHOD("removeCameraFromPool") {
		params[["_cam", objNull]];
		["removeCameraFromPool", [_cam]] CALL_CLASS("DbHandler");
	};
	CLASS_METHOD("destroyCamera") {
		params[["_cam", objNull]];
		["removeCameraFromPool", [_cam]] CALL_CLASS(_self);
		if !(IS_OBJ(_cam)) exitWith {false};
		camDestroy _cam;
		true
	};
	CLASS_METHOD("spawnCamera") {
		params[["_monitor", objNull], ["_renderTarget", ""]];

		if !(IS_VALID_R2T(_renderTarget)) exitWith {objNull};

		private _cam = ["CreateCamera", [_monitor, _renderTarget], _self, [objNull, "", "NONE"]] CALL_CLASS(_self);

		_cam
	};
CLASS_END