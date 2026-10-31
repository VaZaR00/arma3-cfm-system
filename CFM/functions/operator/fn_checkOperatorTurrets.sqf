/*
    Function: CFM_fnc_checkOperatorTurrets
    Author: Vazar
    Description: Checks all turrets of an operator for destroyed camera objects / turret objects and disables dead turrets.
*/

#include "defines.hpp" 

params["_operator"];

if !(IS_OBJ(_operator)) exitWith {-1};

private _allTurrets = _operator getVariable ["CFM_allTurrets", _operator getVariable ["CFM_turrets", []]];
if (_allTurrets isEqualTo []) exitWith {-1};

private _disabledTurrets = _operator getVariable ["CFM_disabledTurrets", []];
private _camObjs = _operator getVariable ["CFM_cameraObjects", createHashMap];
private _activeTurretsObjects = _operator getVariable ["CFM_activeTurretsObjects", createHashMap];

private _hasActiveTurretsObjects = _operator getVariable ["CFM_hasActiveTurretsObjects", -1];
private _aliveActiveTurretsCount = 0;
private _hasActiveTurretObjectsToCheck = (_hasActiveTurretsObjects isNotEqualTo -1);

private _turretsToDisable = [];

{
	private _turretIndex = TURRET_INDEX(_x);
	private _isDestroyed = false;

	// Check proxy cameraObject
	if (_turretIndex in _camObjs) then {
		private _camObj = _camObjs getOrDefault [_turretIndex, objNull];
		if ([_camObj] call CFM_fnc_isCameraObjectDestroyed) then {
			_isDestroyed = true;
		};
	};

	// Check activeTurretsObjects (for static camera objects)
	if (_turretIndex in _activeTurretsObjects) then {
		private _turretObj = _activeTurretsObjects getOrDefault [_turretIndex, objNull];
		if (!IS_OBJ(_turretObj) || {!alive _turretObj}) then {
			_isDestroyed = true;
			[_operator, _turretIndex] call CFM_fnc_removeActiveTurret;
		} else {
			_aliveActiveTurretsCount = _aliveActiveTurretsCount + 1;
		};
	};

	if (_isDestroyed) then {
		if !(_turretIndex in _disabledTurrets) then {
			_turretsToDisable pushBack _turretIndex;
		};
	};
} forEach _allTurrets;

if (_hasActiveTurretObjectsToCheck) then {
	_operator setVariable ["CFM_hasActiveTurretsObjects", _aliveActiveTurretsCount, ACTIVE_VIEWERS_AND_SELF(false)];
};

{
	["CFM_" + "disableTurret", [_operator, _x], true] call CFM_fnc_remoteEvent;
} forEach _turretsToDisable;

private _activeTurrets = _operator getVariable ["CFM_turrets", []];
count _activeTurrets
