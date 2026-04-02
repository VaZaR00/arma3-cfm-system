CLASS(CameraManager)

	/*
		Operator's camerasSet: [monitor, camera, params:[operator, turret, zoom, turretLocal]]
	*/

	METHODS

	METHOD("Init") {
		CFM_allCamerasData = createHashMap;
	};
	METHOD("CreateCamera") {
		params[["_initOperator", objNull], ["_initMonitor", objNull], ["_turret", DRIVER_TURRET_PATH]];

		if !(IS_OBJ(_initOperator)) exitWith {objNull};
		if !(IS_OBJ(_initMonitor)) exitWith {objNull};

		private _cam = [] call CFM_fnc_createCamera;

		if !(IS_OBJ(_cam)) exitWith {objNull};

		private _renderTarget = [] call CFM_fnc_getNextRenderTarget;
		_cam cameraEffect ["internal", "back", _renderTarget];
		
		private _params = [
			["CFM_operator", _operator],
			["CFM_currentMonitor", _currentMonitor],
			["CFM_turret", _turret],
			["CFM_zoom", 1],
			["CFM_renderTarget", _renderTarget]
		];
		["setCameraParam", _params] CALL_CLASS(_self);

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
		params[["_cam", objNull], ["_operator", objNull]];
		["removeCameraFromPool", [_cam]] CALL_CLASS(_self);
		["removeCameraData", [_cam]] CALL_CLASS(_self);
		["removeCameraFromOperator", [_operator, _cam]] CALL_CLASS(_self);
		if !(IS_OBJ(_cam)) exitWith {false};
		camDestroy _cam;
		true
	};
	METHOD("removeCameraData") {
		params[["_camera", objNull]];
		
		if !(IS_OBJ(_camera)) exitWith {false};

		private _allCamerasData = missionNamespace getVariable ["CFM_allCamerasData", createHashMap];
		private _key = hashValue _camera;
		_allCamerasData set [_key, nil];
	};
	METHOD("getCameraData") {
		params[["_camera", objNull]];
		
		if !(IS_OBJ(_camera)) exitWith {createHashMap};

		private _allCamerasData = missionNamespace getVariable ["CFM_allCamerasData", createHashMap];
		private _key = hashValue _camera;
		_allCamerasData getOrDefault [_key, createHashMap];
	};
	METHOD("setCameraParam") {
		if ((_this#0) isEqualType []) exitWith {
			_this apply {
				["setCameraParam", _x, _self, false] CALL_CLASS(_self);
			};
		};
		params[["_camera", objNull], ["_param", ""], ["_val", nil]];
		
		private _cameraData = ["getCameraData", [_camera], _self, createHashMap] CALL_CLASS(_self);
		_cameraData set [_param, _NIL(_val)];
		true
	};
	METHOD("getCameraParam") {
		if ((_this#0) isEqualType []) exitWith {
			_this apply {
				["getCameraParam", _x] CALL_CLASS(_self);
			};
		};
		params[["_camera", objNull], ["_param", ""], ["_def", 0]];
		
		private _cameraData = ["getCameraData", [_camera], _self, createHashMap] CALL_CLASS(_self);
		_cameraData getOrDefault [_param, _def];
	};
	METHOD("getRenderTarget") {
		params[["_camera", objNull]];
		["getCameraParam", [_camera, "CFM_renderTarget"], _self, ""] CALL_CLASS(_self);
	};
	METHOD("setCameraZoom") {
		params[["_operator", objNull], ["_camera", objNull], ["_newzoom", 1]];
		["setCameraParamsToOperator", [_operator, _camera, [nil,nil,_newzoom,nil]], _self, ""] CALL_CLASS(_self);
	};
	METHOD("getCameraOperatorData") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]]];
		
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _data = [];
		{
			{
				if ((_x#1) isEqualTo _cam) exitWith {
					_data = _x;
				};
			} forEach _y;
		} forEach _camerasSet;
		_data
	};
	METHOD("getCameraOperatorParams") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]]];
		
	};
	METHOD("setCameraParamsToOperator") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]], ["_params", []]];
		
		private _camData = ["getCameraOperatorData", [_operator, _cam], _self, []] CALL_CLASS(_self);
		_camData params [["_monitor", objNull], ["_cam", _cam], ["_prevParams", []]];

		if (count _prevParams != 4) then {
			_prevParams resize 4;
		};

		_params params [
			["_operator", _prevParams#0],
			["_turret", _prevParams#1],
			["_zoom", _prevParams#2],
			["_turretLocal", _prevParams#3]
		];
		["removeCameraFromOperator", [_operator, _cam]] CALL_CLASS(_self);
		
		private _newParams = [_operator, _turret, _zoom, _turretLocal];
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turret#0, []];
		_turrCameras pushBackUnique [_monitor, _cam, _newParams];
		_camerasSet set [_turretIndex, _turrCameras];
		_operator setVariable ["CFM_camerasSet", _camerasSet];

		_camerasSet
	};
	METHOD("removeCameraFromOperator") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]]];
		
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		{
			{
				if ((_x#1) isEqualTo _cam) exitWith {
					_y deleteAt _forEachIndex;
				};
			} forEach _y;
		} forEach _camerasSet;
	};
	METHOD("addCameraToOperator") {
		params[["_operator", objNull], ["_cam", objNull, [objNull]], ["_monitor", objNull, [objNull]], ["_turretIndex", -1, [1]]];
		
		private _camparams = 
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		_turrCameras pushBackUnique [_monitor, _cam, []];
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

		_cameras#0#1
	};
CLASS_END