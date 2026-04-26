/*
    Function: CFM_fnc_takeUAVcontorls
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor"];

if !(focusOn isEqualTo player) exitWith {
	"Can't take UAV controls when remote controlling other unit!" _HINT
};

private _drone = _monitor getVariable ["CFM_connectedOperator", objNull];
private _errtext = "Can't connect to drone";

if !(IS_OBJ(_drone)) exitWith {};

private _dSide = side _drone;
private _playerSide = side player;
private _sameSide = _dSide isEqualTo _playerSide;
private _canHack = missionNamespace getVariable ["CFM_canHackDrone", false];

if (!_canHack && !_sameSide) exitWith {
	_errtext _HINT;
};
if (!_sameSide) exitWith {
	// do hack
	[_monitor, _drone, _playerSide] spawn {
		params ["_monitor", "_drone", "_playerSide"];

		private _playerStartPos = getPosASL player;

		[[_drone, _playerSide, clientOwner], {
			params ["_drone", "_side", "_netId"];
			deleteVehicleCrew _drone;
			_side createVehicleCrew _drone;
		}] remoteExecCall ["call", _drone];

		"Hacking drone..." _HINT;
		sleep (missionNamespace getVariable ["CFM_hackDroneTime", 5]);

		private _newSide = side _drone;
		if !(_newSide isEqualTo _playerSide) exitWith {
			"Failed to hack drone" _HINT;
		};

		"Drone hacked!" _HINT;

		[_drone, _playerSide] call CFM_fnc_setOperatorSides;

		if ((_playerStartPos distance (getPosASL player)) > 0.5) exitWith {
			"Drone hacked! But connection canceled because you moved." _HINT;
		};

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
	_errtext _HINT;
};

private _controled = [_drone, _turretName] call CFM_fnc_isUAVControlled;
if (_controled && {!(missionNamespace getVariable ["CFM_canInterceptUAVcontrol", false])}) exitWith {
	"Someone is controlling drone!" _HINT;
};

player connectTerminalToUAV objNull;
player remoteControl objNull;
player switchCamera "internal";

"Connecting..." _HINT;
sleep 0.15;
"" _HINT;

private _connect = player connectTerminalToUAV _drone;

if !(_connect) exitWith {
	_errtext _HINT;
};

[] call CFM_fnc_exitFullScreen;
player remoteControl (_bot);
_drone switchCamera "internal";

CFM_currentControlledUAV = _drone;