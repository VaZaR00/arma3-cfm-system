#include "defines\classDefinesVer1.hpp" 

CLASS(CameraManager)

	/*
		Operator's camerasSet: [monitor, camera, params:[operator, turret, zoom, turretLocal]]
	*/

	METHODS

	METHOD("Init") {
	};
	METHOD("CreateCamera") {
		params[["_monitor", objNull]];
		
		if !(IS_OBJ(_monitor)) exitWith {[objNull, ""]};

		private _cam = [] call CFM_fnc_createCamera;
		
		if !(IS_OBJ(_cam)) exitWith {[objNull, ""]};

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
	METHOD("spawnCamera") {
		params[["_monitor", objNull]];

		private _camData = ["CreateCamera", [_monitor], _self, [objNull, "", "NONE"]] CALL_CLASS(_self);
		private _cam = _camData#0;
		private _r2t = _camData#1;

		if !(IS_OBJ(_cam)) exitWith {["", objNull]};
		if !(IS_VALID_R2T(_r2t)) exitWith {["", _cam]};
		[_r2t, _cam]
	};
CLASS_END