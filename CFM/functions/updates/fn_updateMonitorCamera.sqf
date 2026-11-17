/*
    Function: CFM_fnc_updateMonitorCamera
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull], ["_instId", -1]];
if (_monitor isEqualType []) then {
	_monitor params [["_mObj", objNull], ["_mId", -1]];
	_monitor = _mObj;
	if (_instId < 1) then {_instId = _mId};
};
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};

private _isStatic = MON_GVAR(_monitor, _instId, "CFM_currentCameraIsStatic", false);
private _camera = MON_GVAR(_monitor, _instId, "CFM_currentFeedCam", objNull);
private _opIsDrone = MON_GVAR(_monitor, _instId, "CFM_currentOperatorIsDrone", false);
private _zoomFov = if (_opIsDrone && {!(MGVAR ["CFM_canChangeZoomOnDrones", false])}) then {
	"op"
} else {
	MON_GVAR(_monitor, _instId, "CFM_zoomFov", 1);
};
private _smoothZoom = MON_GVAR(_monitor, _instId, "CFM_currentCameraSmoothZoom", true);
private _doUpdateCamera = MON_GVAR(_monitor, _instId, "CFM_doUpdateCamera", false);
private _offsetReached = true;

private _camSet = if (!_isStatic ||
	// smooth movement mechanic for static cameras
	{
		(_smoothZoom && {
			// zoom interpolation
			private _currentFov = MON_GVAR(_monitor, _instId, "CFM_camInterp_lastFov", _zoomFov);
			if !(_currentFov isEqualType 1) exitWith {true};
			private _fovDiff = abs (_zoomFov - _currentFov);
			_fovDiff > DO_INTERPOLATE_TOLERANCE
		}) ||
		{
			// offset interpolation
			if (_doUpdateCamera isEqualType true) exitWith {_doUpdateCamera};
			if !(_doUpdateCamera isEqualType []) exitWith {false};
			private _currPos = getPosASL _camera;
			private _currDir = vectorDir _camera;
			private _currUp = vectorUp _camera;
			_doUpdateCamera params [["_pos", _currPos, [[]], 3], ["_dir", _currDir, [[]], 3], ["_up", _currUp, [[]], 3]];
			_offsetReached = (
				([_pos, _currPos] call CFM_fnc_compareVectors) &&
				{([_dir, _currDir] call CFM_fnc_compareVectors) &&
				{([_up, _currUp] call CFM_fnc_compareVectors)}}
			);
			if (_offsetReached) then {
				MON_SVAR(_monitor, _instId, "CFM_doUpdateCamera", false);
			};
			!_offsetReached
		}
	}
) then {
	private _operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
	private _turretObj = MON_GVAR(_monitor, _instId, "CFM_connectedTurretObject", _operator);
	private _turret = MON_GVAR(_monitor, _instId, "CFM_currentTurret", [-1]);
	private _turLocal = MON_GVAR(_monitor, _instId, "CFM_turretLocal", false);
	private _camPosFunc = MON_GVAR(_monitor, _instId, "CFM_cameraPosFunc", {[]});
	private _pointParams = MON_GVAR(_monitor, _instId, "CFM_currentCamPointParams", []);
	private _doInterpolation = MON_GVAR(_monitor, _instId, "CFM_camDoInterpolation", false);
	if (_offsetReached && {!(_doUpdateCamera isEqualTo 0)}) then {
		MON_SVAR(_monitor, _instId, "CFM_doUpdateCamera", false);
	};
	[_camera, [_operator, _turretObj, _turret, _turLocal, _pointParams, _zoomFov, [_monitor, _instId], _doInterpolation, _smoothZoom], _camPosFunc] call CFM_fnc_updateCamera;
} else {false};

if (_doUpdateCamera isEqualTo 0) then {
	// case for moving camera do interpolation toggle
	private _prevCamPos = MON_GVAR(_monitor, _instId, "CFM_cam_prevSetPos", []);
	if (_prevCamPos isEqualTo []) then {
		// initial set
		MON_SVAR(_monitor, _instId, "CFM_cam_prevSetPos", +_camSet)
	} else {
		if (_prevCamPos isEqualTo _camSet) exitWith {
			// camera stopped moving
			MON_SVAR(_monitor, _instId, "CFM_camDoInterpolation", false);
			MON_SVAR(_monitor, _instId, "CFM_doUpdateCamera", nil);
			MON_SVAR(_monitor, _instId, "CFM_cam_prevSetPos", nil);
		};
		// still moving
		MON_SVAR(_monitor, _instId, "CFM_cam_prevSetPos", +_camSet);
	};
};

// upd pip
private _updatePip = MON_GVAR(_monitor, _instId, "CFM_doUpdatePip", false);
if (_updatePip) then {
	private _feedActive = MON_GVAR(_monitor, _instId, "CFM_feedActive", false);
	if !(_feedActive) exitWith {};
	private _currPip = MON_GVAR(_monitor, _instId, "CFM_currentPiPEffect", 0);
	[[_monitor, _instId], _currPip] call CFM_fnc_setMonitorPiPEffect;
	MON_SVAR(_monitor, _instId, "CFM_doUpdatePip", false);
};

true