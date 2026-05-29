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

if !((_operator getVariable ["CFM_operatorSet", false]) isEqualTo true) exitWith {1};

private _turretIndex = TURRET_INDEX(_turret);
private _turrIdxStr = TURR_INDX_STR(_turretIndex);

if (isMultiplayer && {_useCooldown && {
	private _prevTimeSet = _operator getVariable ["CFM_prevTimeSetLocalCamVector" + _turrIdxStr, 0];
	(diag_tickTime - _prevTimeSet) < SET_LOCAL_CAM_VECTORS_TIMEOUT;
}}) exitWith {2};

private _turretsInstances = _operator getVariable ["CFM_turretsInstances", createHashMap];

if !(_turretIndex in _turretsInstances) exitWith {3};

private _turretData = _turretsInstances getOrDefault [_turretIndex, []];
_turretData params [["_turretInstanceId", -1], ["_turretObject", objNull]];

if (_onlyIfTurrLocal && {!(TURRET_VAR(_isLocal, false))}) exitWith {4};

private _dirVarName = "CFM_currentTurretDirMS" + _turrIdxStr;
private _upVarName = "CFM_currentTurretUpMS" + _turrIdxStr;
// private _posVarName = "CFM_currentTurretPosMS" + str _turretIndex;
private _camPosFunc = TURRET_VAR(_camPosFunc, CAM_POS_FUNC_DEF);
private _pointParams = TURRET_VAR(_pointParams, []);
private _posVDUp = [objNull, [_operator, _turretObject, [_turretIndex], true, _pointParams, nil, objNull, false, false, false, false], _camPosFunc] call CFM_fnc_updateCamera;
_posVDUp params [["_pos", NULL_VECTOR], ["_vdup", []]];
_vdup params [["_dir", DEF_DIR], ["_up", DEF_UP]];
private _prevDir = _operator getVariable [_dirVarName, []];
private _prevUp = _operator getVariable [_upVarName, []];
// private _prevPos = _operator getVariable [_posVarName, []];
private _currDirMS = _operator vectorWorldToModelVisual _dir;
private _currUpMS = _operator vectorWorldToModelVisual _up;
// private _currPosMS = _operator worldToModelVisual (ASLToAGL _pos);

private _updated = false;
private _targets = ACTIVE_VIEWERS_AND_SELF(false);
if !(_currDirMS isEqualTo _prevDir) then {
	_updated = true;
	_operator setVariable [_dirVarName, _currDirMS, _targets];
};
if !(_currUpMS isEqualTo _prevUp) then {
	_updated = true;
	_operator setVariable [_upVarName, _currUpMS, _targets];
};
// if !(_currPosMS isEqualTo _prevPos) then {
// 	_updated = true;
// 	_operator setVariable [_posVarName, _currPosMS, _targets];
// };
if (cameraOn isEqualTo _operator) then {
	[_operator] call CFM_fnc_updateOperatorZoom;
};
_operator setVariable ["CFM_prevTimeSetLocalCamVector" + _turrIdxStr, diag_tickTime];

_updated