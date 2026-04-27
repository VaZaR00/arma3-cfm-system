/*
    Function: CFM_fnc_updateOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_controlledUnit", objNull], ["_turret", -2]];

private _currVeh = vehicle PLAYER_;
if !(_currVeh isEqualTo PLAYER_) then {
	[_currVeh] call CFM_fnc_updateOperatorZoom;
};

if !(IS_OBJ(_controlledUnit)) then {
	_controlledUnit = focusOn;
};
private _namespace = if (isServer) then {
	if (IS_OBJ(_controlledUnit)) then {_controlledUnit} else {missionNamespace};
} else {
	if (IS_OBJ(_controlledUnit)) then {_controlledUnit} else {PLAYER_};
};
private _prevControlledUnit = _namespace getVariable ["CFM_lastControlledUnit", objNull];
if !(_prevControlledUnit isEqualTo _controlledUnit) then {
	// unit changed
	_namespace setVariable ["CFM_lastControlledUnit", _controlledUnit];
	_namespace setVariable ["CFM_lastControlledUnitTurretIndex", nil];
	_namespace setVariable ["CFM_lastControlledUnitIsTurrLocal", nil];
	_namespace setVariable ["CFM_lastControlledUnitMonitor", nil];
	// for remote controlled menu handling
	_namespace setVariable ['CFM_menuActive', false];
};

if (isNull _controlledUnit) exitWith {};
if (_controlledUnit isEqualTo PLAYER_) exitWith {};
private _controlledObj = vehicle _controlledUnit;

if !(local _controlledObj) exitWith {};

private _turretIndex = if (_turret < -1) then {
	_namespace getVariable ["CFM_lastControlledUnitTurretIndex", _turret]
} else {
	_turret
};
private _turrLocal = _namespace getVariable ["CFM_lastControlledUnitIsTurrLocal", false];
private _monitor = _namespace getVariable ["CFM_lastControlledUnitMonitor", objNull];
if (_turretIndex < -1) then {
	private _role = assignedVehicleRole _controlledUnit;
	if (_role isEqualTo []) exitWith {};
	_turretIndex = _role call CFM_fnc_getTurretIndex;
	private _turrsParams = _controlledObj getVariable "CFM_turretsParams";
	if (isNil "_turrsParams") exitWith {};
	if !(_turrsParams isEqualType createHashMap) exitWith {};
	private _currTurrParams = _turrsParams get _turretIndex;
	if (isNil "_currTurrParams") exitWith {};
	if !(_currTurrParams isEqualType createHashMap) exitWith {};
	_turrLocal = _currTurrParams getOrDefault ["IsTurretLocal", false];
	private _monitorsSet = _controlledObj getVariable ["CFM_monitorsSet", createHashMap];
	private _monitors = _monitorsSet getOrDefault [_turretIndex, []];
	_monitor = _monitors#0;
	if (isNil "_monitor") exitWith {};
	_namespace setVariable ["CFM_lastControlledUnitTurretIndex", _turretIndex];
	_namespace setVariable ["CFM_lastControlledUnitIsTurrLocal", _turrLocal];
	_namespace setVariable ["CFM_lastControlledUnitMonitor", _monitor];
};

if (isNil "_monitor") exitWith {};
if !(IS_OBJ(_monitor)) exitWith {};

// LOCAL TURRET ORIENTATION
if (_turrLocal) then {
	private _prevTimeSet = missionNamespace getVariable ["CFM_prevTimeSetLocalCamVector", 0];
	private _cooldown = (diag_tickTime - _prevTimeSet) < SET_LOCAL_CAM_VECTORS_TIMEOUT;
	if !(_cooldown) then {
		private _dirVarName = "CFM_currentTurretDirMS" + str _turretIndex;
		private _upVarName = "CFM_currentTurretUpMS" + str _turretIndex;
		private _posVarName = "CFM_currentTurretPosMS" + str _turretIndex;
		private _camPosFunc = _monitor getVariable ["CFM_cameraPosFunc", {[NULL_VECTOR, [NULL_VECTOR, NULL_VECTOR]]}];
		private _pointParams = _monitor getVariable ["CFM_currentCamPointParams", []];
		private _turretObj = _monitor getVariable ["CFM_connectedTurretObject", objNull];
		private _posVDUp = [objNull, [_controlledObj, _turretObj, [_turretIndex], true, _pointParams, nil, _monitor, false, false, false, false], _camPosFunc] call CFM_fnc_updateCamera;
		_posVDUp params [["_pos", NULL_VECTOR], ["_vdup", []]];
		_vdup params [["_dir", NULL_VECTOR], ["_up", NULL_VECTOR]];
		private _prevDir = _controlledObj getVariable [_dirVarName, []];
		private _prevUp = _controlledObj getVariable [_upVarName, []];
		private _prevPos = _controlledObj getVariable [_posVarName, []];
		private _currDirMS = _controlledObj vectorWorldToModelVisual _dir;
		private _currUpMS = _controlledObj vectorWorldToModelVisual _up;
		private _currPosMS = _controlledObj worldToModelVisual (ASLToAGL _pos);
		if !(_currDirMS isEqualTo _prevDir) then {
			_controlledObj setVariable [_dirVarName, _currDirMS, MONITOR_VIEWERS_AND_SELF(false)];
		};
		if !(_currUpMS isEqualTo _prevUp) then {
			_controlledObj setVariable [_upVarName, _currUpMS, MONITOR_VIEWERS_AND_SELF(false)];
		};
		if !(_currPosMS isEqualTo _prevPos) then {
			_controlledObj setVariable [_posVarName, _currPosMS, MONITOR_VIEWERS_AND_SELF(false)];
		};
		[_controlledObj] call CFM_fnc_updateOperatorZoom;
		missionNamespace setVariable ["CFM_prevTimeSetLocalCamVector", diag_tickTime];
	};
};
