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

private _generalUpdate = false;
if !(IS_OBJ(_controlledUnit)) then {
	_generalUpdate = true;
	_controlledUnit = focusOn;
};
private _controlledObj = vehicle _controlledUnit;

private _player = PLAYER_;
if (_generalUpdate) then {
	private _currVeh = vehicle _player;
	if !(_currVeh isEqualTo _player) then {
		[_currVeh] call CFM_fnc_updateOperatorZoom;
	};
};

if !(local _controlledObj) exitWith {false};
if (isNull _controlledUnit) exitWith {false};
if (_controlledUnit isEqualTo _player) exitWith {false};

private _prevUnit = _player getVariable ["CFM_lastControlledUnit", _controlledUnit];

if !(_prevUnit isEqualTo _controlledUnit) then {
	// unit changed
	_player setVariable ["CFM_lastControlledUnitTurretIndex", nil];
	_player setVariable ["CFM_lastControlledUnit", _controlledUnit];
	// for remote controlled menu handling
	_prevUnit setVariable ['CFM_menuActive', false];
	_player setVariable ['CFM_menuActive', false];
};

private _turretIndex = if (_turret < -1) then {
	_player getVariable ["CFM_lastControlledUnitTurretIndex", _turret]
} else {
	_turret
};
if (_turretIndex < -1) then {
	private _role = assignedVehicleRole _controlledUnit;
	if (_role isEqualTo []) exitWith {};
	_turretIndex = _role call CFM_fnc_getTurretIndex;
	_player setVariable ["CFM_lastControlledUnitTurretIndex", _turretIndex];
};

[_controlledObj, _turretIndex] call CFM_fnc_updateTurretCamera;