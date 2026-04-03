CLASS(CameraManager)

	/*
		Operator's camerasSet: [monitor, camera, params:[operator, turret, zoom, turretLocal]]
	*/

	METHODS

	METHOD("Init") {
		CFM_allCamerasData = createHashMap;
		CFM_camerasSet = createHashMap;
	};
	METHOD("CreateCamera") {
		params[["_monitor", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {objNull};

		private _cam = [] call CFM_fnc_createCamera;

		if !(IS_OBJ(_cam)) exitWith {objNull};

		private _renderTarget = [] call CFM_fnc_getNextRenderTarget;
		_cam cameraEffect ["internal", "back", _renderTarget];
		
		["setMonitorCamera", [_self]] CALL_CLASS(_self);
		["addCameraToPool", [_self]] CALL_CLASS(_self);

		[_cam, _renderTarget]
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
		["removeCameraFromPool", [_cam]] CALL_CLASS(_self);
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
	METHOD("setCameraData") {
		params[["_camera", objNull], ["_val", nil]];
		
		if !(IS_OBJ(_camera)) exitWith {-1};

		private _allCamerasData = missionNamespace getVariable ["CFM_allCamerasData", createHashMap];
		private _key = hashValue _camera;
		_allCamerasData set [_key, _NIL(_val)];
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
		["setCameraData", [_camera, _cameraData]] CALL_CLASS(_self);
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
		["getCameraParam", [_camera, "CFM_renderTarget", ""], _self, ""] CALL_CLASS(_self);
	};
	METHOD("spawnCamera") {
		params[["_monitor", objNull]];

		private _camData = ["CreateCamera", [_monitor], _self, objNull] CALL_CLASS(_self);
		private _cam = _camData#0;
		private _r2t = _camData#1;

		if !(IS_OBJ(_cam)) exitWith {["", objNull]};
		if !(IS_VALID_R2T(_r2t)) exitWith {["", _cam]};
		[_r2t, _cam]
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
		
		private _turretIndex = _turret#0;
		private _newParams = [_operator, _turret, _zoom, _turretLocal];
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
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
		params[
			["_operator", objNull], 
			["_cam", objNull, [objNull]], 
			["_monitor", objNull, [objNull]], 
			["_turretIndex", -1, [1]]
		];
		
		private _turrLocal = _operator getVariable ["CFM_doCheckTurretLocality", false];
		private _camParams = [_operator, [_turretIndex], 1, _turrLocal];
		private _camerasSet = _operator getVariable ["CFM_camerasSet", createHashMap];
		private _turrCameras = _camerasSet getOrDefault [_turretIndex, []];
		_turrCameras pushBackUnique [_monitor, _cam, _camParams];
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
			_cam
		};

		_cameras#0#1
	};
	METHOD("setMonitorCamera") {
		params[["_monitor", objNull], ["_camera", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {false};
		if !(IS_OBJ(_camera)) exitWith {false};
		
		private _camerasSet = missionNamespace getVariable ["CFM_camerasSet", createHashMap];
		private _hashVal = hashValue _monitor;
		_camerasSet set [_hashVal, objNull];
		missionNamespace setVariable ["CFM_camerasSet", _camerasSet];
		true
	};
	METHOD("getMonitorCamera") {
		params[["_monitor", objNull]];

		if !(IS_OBJ(_monitor)) exitWith {objNull};
		
		private _camerasSet = missionNamespace getVariable ["CFM_camerasSet", createHashMap];
		private _hashVal = hashValue _monitor;
		_camerasSet getOrDefault [_hashVal, objNull];
	};
CLASS_END