/*
    Function: CFM_fnc_updateOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[
	["_controlledUnit", objNull], 
	["_turret", -2]
];

private _controlledObj = _controlledUnit;
private _generalUpdate = false;
if !(IS_OBJ(_controlledUnit)) then {
	_generalUpdate = true;
	_controlledUnit = focusOn;
	_controlledObj = vehicle _controlledUnit;
};

private _player = if (isDedicated) then {missionNamespace} else {PLAYER_};
if (_generalUpdate) then {
	private _currVeh = vehicle _player;
	if !(_currVeh isEqualTo _player) then {
		[_currVeh] call CFM_fnc_updateOperatorZoom;
	};

	if !(local _controlledObj) exitWith {false};
	if (isNull _controlledUnit) exitWith {false};
	if (_controlledUnit isEqualTo _player) exitWith {false};

	private _prevUnit = missionNamespace getVariable ["CFM_lastControlledUnit", _controlledUnit];

	if !(_prevUnit isEqualTo _controlledUnit) then {
		// unit changed
		missionNamespace setVariable ["CFM_lastControlledUnitTurretIndex", nil];
		missionNamespace setVariable ["CFM_lastControlledUnit", _controlledUnit];
		// for remote controlled menu handling
		_prevUnit setVariable ['CFM_menuActive', false];
		_player setVariable ['CFM_menuActive', false];
	};
};

private _turretIndex = if (_turret < -1) then {
	missionNamespace getVariable ["CFM_lastControlledUnitTurretIndex", _turret]
} else {
	_turret
};
if (_turretIndex < -1) then {
	private _role = assignedVehicleRole _controlledUnit;
	if (_role isEqualTo []) exitWith {};
	_turretIndex = _role call CFM_fnc_getTurretIndex;
	missionNamespace setVariable ["CFM_lastControlledUnitTurretIndex", _turretIndex];
};

[_controlledObj, _turretIndex] call CFM_fnc_updateTurretCamera;