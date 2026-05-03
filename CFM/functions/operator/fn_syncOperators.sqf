/*
    Function: CFM_fnc_syncOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _updOps = missionNamespace getVariable ["CFM_operatorsToUpdate", []];
if !(_updOps isEqualType []) then {_updOps = [_updOps]};
if (missionNamespace getVariable ["CFM_makeCamDataSync", false]) then {
	_updOps = _updOps + (missionNamespace getVariable ["CFM_Operators", []]);
	missionNamespace setVariable ["CFM_makeCamDataSync", false];
};
private _targets = MONITOR_VIEWERS_AND_SELF(false);
{
	private _operator = _x;
	if !(IS_OBJ(_operator)) then {continue};
	// CAM DATA
	private _turrets = _operator getVariable ["CFM_turrets", [[-1]]];
	{
		private _turretIndex = TURRET_INDEX(_x);
		private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
		private _currDir = _operator getVariable [_dirVarName, []];
		private _currUp = _operator getVariable [_upVarName, []];
		_operator setVariable [_dirVarName, _currDir, _targets];
		_operator setVariable [_upVarName, _currUp, _targets];
	} forEach _turrets;
	// ZOOM
	private _currentZoom = _operator getVariable ["CFM_prevZoomLocalFov", 1];
	_operator setVariable ["CFM_prevZoomLocalFov", _currentZoom, _targets];
	// ACTIVE TURRETS
	private _hasActiveTurretsObjects = _operator getVariable ["CFM_hasActiveTurretsObjects", -1];
	_operator setVariable ["CFM_hasActiveTurretsObjects", _hasActiveTurretsObjects, _targets];
	private _activeTurretsObjects = _operator getVariable ["CFM_activeTurretsObjects", createHashMap];
	_operator setVariable ["CFM_activeTurretsObjects", _activeTurretsObjects, _targets];
	// TURRET PARAMS
	private _turretsParams = _operator getVariable ["CFM_turretsParams", createHashMap];
	_operator setVariable ["CFM_turretsParams", _turretsParams, _targets];
} forEach _updOps;
missionNamespace setVariable ["CFM_operatorsToUpdate", []];
_updOps
