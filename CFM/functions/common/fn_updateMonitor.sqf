/*
    Function: CFM_fnc_updateMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];
// params[["_monitorParams", []]];

// _monitorParams params [
// 	["_isStatic", false],
// 	["_camera", objNull],
// 	["_zoomFov", 1],
// 	["_smoothZoom", true],
// 	["_doUpdateCamera", false],
// 	["_var", false],
// 	["_var", false],
// 	["_var", false],
// ];

// private _monitorDisplayId = _monitor getVariable ["CFM_monitorUid", ""];
// private _monitorDisplay = findDisplay _monitorDisplayId;
// private _monitorUIdisplay = findDisplay (_monitorDisplayId + "_ui");
// private _monitorEffectsDisplay = findDisplay (_monitorDisplayId + "_effects");
// private _monitorRenderDisplay = findDisplay (_monitorDisplayId + "_render");

// //----------------- UPDATE SIGNAL -----------------------
// //-------------------------------------------------------

// if (_weakConnection) exitWith {
// 	[] call CFM_fnc_monitorWeakConnection;
// 	0
// };
// if (_signalLost) exitWith {false};

//----------------- UPDATE EFFECTS -----------------------
//-------------------------------------------------------

//----------------- UPDATE CAMERA -----------------------
	private _isStatic = _monitor getVariable ["CFM_currentCameraIsStatic", false];
	private _camera = _monitor getVariable ["CFM_currentFeedCam", objNull];
	private _zoomFov = _monitor getVariable ["CFM_zoomFov", 1];
	private _smoothZoom = _monitor getVariable ["CFM_currentCameraSmoothZoom", true];
	private _doUpdateCamera = _monitor getVariable ["CFM_doUpdateCamera", false];
	private _offsetReached = true;

	private _camSet = if (!_isStatic ||
		// smooth movement mechanic for static cameras
		{
			(_smoothZoom && {
				// zoom interpolation
				private _currentFov = _monitor getVariable ["CFM_camInterp_lastFov", _zoomFov];
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
					_monitor setVariable ["CFM_doUpdateCamera", false];
				};
				!_offsetReached
			}
		}
	) then {
		private _operator = _monitor getVariable ["CFM_connectedOperator", objNull];
		private _turretObj = _monitor getVariable ["CFM_connectedTurretObject", _operator];
		private _turret = _monitor getVariable ["CFM_currentTurret", [-1]];
		private _turLocal = _monitor getVariable ["CFM_turretLocal", false];
		private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {[]}];
		private _pointParams = _monitor getVariable ["CFM_currentCamPointParams", []];
		private _doInterpolation = _monitor getVariable ["CFM_camDoInterpolation", false];
		if (_offsetReached && {!(_doUpdateCamera isEqualTo 0)}) then {
			_monitor setVariable ["CFM_doUpdateCamera", false];
		};
		[_camera, [_operator, _turretObj, _turret, _turLocal, _pointParams, _zoomFov, _monitor, _doInterpolation, _smoothZoom], _camPosFunc] call CFM_fnc_updateCamera;
	} else {false};

	if (_doUpdateCamera isEqualTo 0) then {
		// case for moving camera do interpolation toggle
		private _prevCamPos = _monitor getVariable ["CFM_cam_prevSetPos", []];
		if (_prevCamPos isEqualTo []) then {
			// initial set
			_monitor setVariable ["CFM_cam_prevSetPos", +_camSet]
		} else {
			if (_prevCamPos isEqualTo _camSet) exitWith {
				// camera stopped moving
				_monitor setVariable ["CFM_camDoInterpolation", false];
				_monitor setVariable ["CFM_doUpdateCamera", nil];
				_monitor setVariable ["CFM_cam_prevSetPos", nil];
			};
			// still moving
			_monitor setVariable ["CFM_cam_prevSetPos", +_camSet];
		};
	};

	// upd pip
	private _updatePip = _monitor getVariable ["CFM_doUpdatePip", false];
	if (_updatePip) then {
		private _feedActive = _monitor getVariable ["CFM_feedActive", false];
		if !(_feedActive) exitWith {};
		private _currPip = _monitor getVariable ["CFM_currentPiPEffect", 0];
		[_monitor, _currPip] call CFM_fnc_setMonitorPiPEffect;
		_monitor setVariable ["CFM_doUpdatePip", false];
	};

	true
//-------------------------------------------------------