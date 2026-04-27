/*
    Function: CFM_fnc_updateTurretCamera
    Author: Vazar
    Description:
*/

#include "defines.hpp" 

params[
	["_operator", objNull], 
	["_turret", -2],
	["_onlyIfTurrLocal", true],
	["_useCooldown", true]
];

if !((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true) exitWith {false};

if (isMultiplayer && {_useCooldown && {
	private _prevTimeSet = _operator getVariable ["CFM_prevTimeSetLocalCamVector", 0];
	(diag_tickTime - _prevTimeSet) < SET_LOCAL_CAM_VECTORS_TIMEOUT;
}}) exitWith {false};

private _turretIndex = TURRET_INDEX(_turret);

private _turretsParams = _operator getVariable ["CFM_turretsParams", createHashMap];
private _turretData = _turretsParams getOrDefault [_turretIndex, createHashMap];

if (_onlyIfTurrLocal && {_turretData getOrDefault ["isLocal", false]}) exitWith {false};

private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
private _posVarName = "CFM_currentTurretPosMS" + str _turretIndex;
private _camPosFunc = _turretData getOrDefault ["camPosFunc", CAM_POS_FUNC_DEF];
private _pointParams = _turretData getOrDefault ["pointParams", []];
private _turretObj = _turretData getOrDefault ["turretObject", _operator];
private _posVDUp = [objNull, [_operator, _turretObj, [_turretIndex], true, _pointParams, nil, objNull, false, false, false, false], _camPosFunc] call CFM_fnc_updateCamera;
_posVDUp params [["_pos", NULL_VECTOR], ["_vdup", []]];
_vdup params [["_dir", NULL_VECTOR], ["_up", NULL_VECTOR]];
private _prevDir = _operator getVariable [_dirVarName, []];
private _prevUp = _operator getVariable [_upVarName, []];
private _prevPos = _operator getVariable [_posVarName, []];
private _currDirMS = _operator vectorWorldToModelVisual _dir;
private _currUpMS = _operator vectorWorldToModelVisual _up;
private _currPosMS = _operator worldToModelVisual (ASLToAGL _pos);

private _updated = false;
if !(_currDirMS isEqualTo _prevDir) then {
	_updated = true;
	_operator setVariable [_dirVarName, _currDirMS, MONITOR_VIEWERS_AND_SELF(false)];
};
if !(_currUpMS isEqualTo _prevUp) then {
	_updated = true;
	_operator setVariable [_upVarName, _currUpMS, MONITOR_VIEWERS_AND_SELF(false)];
};
if !(_currPosMS isEqualTo _prevPos) then {
	_updated = true;
	_operator setVariable [_posVarName, _currPosMS, MONITOR_VIEWERS_AND_SELF(false)];
};
[_operator] call CFM_fnc_updateOperatorZoom;
_operator setVariable ["CFM_prevTimeSetLocalCamVector", diag_tickTime];

_updated