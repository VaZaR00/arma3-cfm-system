/*
    Function: CFM_fnc_takeUAVcontorls
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor"];

private _drone = _monitor getVariable ["CFM_connectedOperator", objNull];
private _errtext = "Can't connect to drone";

if !(IS_OBJ(_drone)) exitWith {};

private _dSide = side _drone;
private _playerSide = side PLAYER_;
private _sameSide = _dSide isEqualTo _playerSide;
private _canHack = missionNamespace getVariable ["CFM_canHackDrone", false];

if (!_canHack && !_sameSide) exitWith {
	hint _errtext;
};
if (!_sameSide) exitWith {
	// do hack
	[_monitor, _drone, _playerSide] spawn {
		params ["_monitor", "_drone", "_playerSide"];

		[[_drone, _playerSide, clientOwner], {
			params ["_drone", "_side", "_netId"];
			deleteVehicleCrew _drone;
			_side createVehicleCrew _drone;
		}] remoteExecCall ["call", _drone];

		hint "Hacking drone...";
		sleep (missionNamespace getVariable ["CFM_hackDroneTime", 5]);

		private _newSide = side _drone;
		if !(_newSide isEqualTo _playerSide) exitWith {
			hint "Failed to hack drone";
		};

		hint "Drone hacked!";

		[_monitor] spawn CFM_fnc_takeUAVcontorls;
	};
};

private _dDriver = driver _drone;
private _dGunner = gunner _drone;

private _bot = _dDriver;
private _turretName = "DRIVER";
private _currTurret = _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH];
if (_currTurret isEqualTo GUNNER_TURRET_PATH) then {
	_bot = _dGunner;
	if (isNull _bot) then {
		_bot = _dDriver;
	} else {
		_turretName = "GUNNER";
	};
};
if (isNil "_bot" || {!IS_OBJ(_bot)}) exitWith {
	hint _errtext;
};

private _controled = [_drone, _turretName] call CFM_fnc_isUAVControlled;
if (_controled && {!(missionNamespace getVariable ["CFM_canInterceptUAVcontrol", false])}) exitWith {
	hint "Someone is controlling drone!";
};

PLAYER_ connectTerminalToUAV objNull;
PLAYER_ switchCamera "internal";

hint "Connecting...";
sleep 0.15;
hint "";

private _connect = PLAYER_ connectTerminalToUAV _drone;

if !(_connect) exitWith {
	hint _errtext;
};

[] call CFM_fnc_exitFullScreen;
PLAYER_ remoteControl (_bot);
_drone switchCamera "internal";
