/*
    Function: CFM_fnc_updateCamera
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params [["_cam", objNull], ["_cameraParams", []], ["_camPosFunc", CFM_fnc_camPosVehTurret]];
_cameraParams params [
	["_operator", objNull],
	["_turretObject", objNull],
	["_turret", [-1]],
	["_turretLocal", false],
	["_pointParams", []],
	["_zoomFov", 1],
	["_monitor", objNull],
	["_doInterpolation", false],
	["_smoothZoom", true],
	["_doSetCam", true],
	["_setLocalOpTurretDir", true]
];
private _turretIndex = _turret#0;
private _camExists = IS_OBJ(_cam);
// private _operatorLocal = local _operator;

// ZOOM
private _fov = if ((_zoomFov isEqualType 1) && {(_zoomFov > 0) && (_zoomFov <= 1)}) then {
	_zoomFov
} else {
	if (_zoomFov isEqualTo "op") exitWith {
		_operator getVariable ['CFM_prevZoomLocalFov', getObjectFov _operator];
	};
};

// POS AN VECTOR DIR AND UP
private _posData = [_turretObject, _pointParams] call _camPosFunc;
_posData params [
	["_pos", getPosASL _operator],
	["_dir", vectorDir _operator],
	["_up", vectorUp _operator]
];
if (count _pos != 3) then {
	_pos = getPosASL _operator;
};
if (count _dir != 3) then {
	_dir = vectorDir _operator;
};
if (count _up != 3) then {
	_up = vectorUp _operator;
};

if (_turretLocal && {_setLocalOpTurretDir}) then {
	private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
	private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
	private _localDirMS = _operator getVariable [_dirVarName, []];
	private _localUpMS = _operator getVariable [_upVarName, []];
	if ((_localDirMS isEqualType []) && {(count _localDirMS == 3)}) then {
		_dir = _operator vectorModelToWorldVisual _localDirMS;
	};
	if ((_localUpMS isEqualType []) && {(count _localUpMS == 3)}) then {
		_up = _operator vectorModelToWorldVisual _localUpMS;
	};
};

private _newFov = _fov;
private _newPos = _pos;
private _newDir = _dir;
private _newUp = _up;
if (_doInterpolation) then {
	private _interpTightnessOffsetVal = MGVAR ["CFM_camInterpolation_tightnessOffset", "5"];
	if !(_interpTightnessOffsetVal isEqualType "") then {
		_interpTightnessOffsetVal = str _interpTightnessOffsetVal;
		missionNamespace setVariable ["CFM_optimizeByDistance", _interpTightnessOffsetVal];
	};
	private _interpTightnessOffset = 0.01 max (parseNumber (_interpTightnessOffsetVal));
	// private _lastPos = _monitor getVariable ["CFM_camInterp_lastPos", _pos];
	private _lastDir = _monitor getVariable ["CFM_camInterp_lastDir", _dir];
	private _lastUp = _monitor getVariable ["CFM_camInterp_lastUp", _up];
	// _newPos = [_lastPos, _pos, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
	_newDir = [_lastDir, _dir, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
	_newUp = [_lastUp, _up, _interpTightnessOffset] call CFM_fnc_timeInterpolate;
	// _monitor setVariable ["CFM_camInterp_lastPos", _newPos];
	_monitor setVariable ["CFM_camInterp_lastDir", _newDir];
	_monitor setVariable ["CFM_camInterp_lastUp", _newUp];
};
if (_smoothZoom) then {
	private _interpTightnessZoomVal = 0.01 max (parseNumber (MGVAR ["CFM_camInterpolation_tightnessZoom", "10"]));
	if !(_interpTightnessZoomVal isEqualType "") then {
		_interpTightnessZoomVal = str _interpTightnessZoomVal;
		missionNamespace setVariable ["CFM_optimizeByDistance", _interpTightnessZoomVal];
	};
	private _interpTightnessZoom = 0.01 max (parseNumber (_interpTightnessZoomVal));
	private _lastFov = _monitor getVariable ["CFM_camInterp_lastFov", _fov];
	_newFov = [_lastFov, _fov, _interpTightnessZoom] call CFM_fnc_timeInterpolate;
	_monitor setVariable ["CFM_camInterp_lastFov", _newFov];
};
if (_camExists && _doSetCam) then {
	_cam setPosASL _newPos;
	_cam setVectorDirAndUp [_newDir, _newUp];
	_cam camSetFov _newFov;
	_cam camCommit 0;
};

[_newPos, [_newDir, _newUp]]
