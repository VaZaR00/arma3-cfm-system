
LOCAL SINGLETON_CLASS(CameraManager)

	/*
		Operator's camerasSet: [monitor, camera, params:[operator, turret, zoom, turretLocal]]
	*/

	PRIVATE LOCAL METHOD("Init") {
	};
	PRIVATE LOCAL METHOD("CreateCamera") {
		params[["_monitor", objNull], ["_renderTarget", ""]];
		
		if !(IS_OBJ(_monitor)) exitWith {[objNull, ""]};

		private _cam = [] call CFM_fnc_createCamera;
		
		if !(IS_OBJ(_cam)) exitWith {[objNull, ""]};

		_cam cameraEffect ["internal", "back", _renderTarget];
		
		["addCameraToPool", [_selfObj]] CALL_SELF;

		_cam
	};
	PRIVATE LOCAL METHOD("addCameraToPool") {
		params[["_cam", objNull]];
		["addCameraToPool", [_cam]] CALL_CLASS("DbHandler");
	};
	PRIVATE LOCAL METHOD("removeCameraFromPool") {
		params[["_cam", objNull]];
		["removeCameraFromPool", [_cam]] CALL_CLASS("DbHandler");
	};
	PRIVATE LOCAL METHOD("destroyCamera") {
		params[["_cam", objNull], ["_renderTarget", ""]];
		["removeCameraFromPool", [_cam]] CALL_SELF;
		if !(IS_OBJ(_cam)) exitWith {false};
		_cam cameraEffect ["terminate", "back", _renderTarget];
		camDestroy _cam;
		true
	};
	PRIVATE LOCAL METHOD("spawnCamera") {
		params[["_monitor", objNull], ["_renderTarget", ""]];

		if !(IS_VALID_R2T(_renderTarget)) exitWith {objNull};
		if !(hasInterface) exitWith {objNull};

		private _cam = ["CreateCamera", [_monitor, _renderTarget], objNull] CALL_SELF;

		_cam
	};
CLASS_END