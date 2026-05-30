/*
    Function: CFM_fnc_hackDrone
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_drone", "_side", ["_takeControls", false], ["_monitor", objNull], ["_imidiate", false], ["_hint", true]];

private _playerStartPos = getPosASL player;

[[_drone, _side, clientOwner], {
	params ["_drone", "_side", "_netId"];
	deleteVehicleCrew _drone;
	_side createVehicleCrew _drone;
}, _drone] call CFM_fnc_remoteExec;

if (_hint) then {
	"Hacking drone..." _HINT;
};

if !(_imidiate) then {
	sleep (missionNamespace getVariable ["CFM_hackDroneTime", 5]);
};

private _newSide = side _drone;
if !(_newSide isEqualTo _side) exitWith {
	if (_hint) then {
		"Failed to hack drone" _HINT;
	};
	false
};

if (_hint) then {
	"Drone hacked!" _HINT;
};

[_drone, _side, true] call CFM_fnc_setOperatorSides;

if (_takeControls) then {
	if ((_playerStartPos distance (getPosASL player)) > 0.5) exitWith {
		"Drone hacked! But connection canceled because you moved." _HINT;
	};

	[_monitor] spawn CFM_fnc_takeUAVcontorls;
};

true