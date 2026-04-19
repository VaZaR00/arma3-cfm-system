/*
	Name: CFM_fnc_setMonitor

	Description: 
		Sets obj as monitor

	Return: true os succes, false or any if not

	Arguments:
		1. _monitor [object]
		2. _sides [Array[side], side] - defines which operators sides it have access to
		3. _isHandMonitorDisplay [bool] - if its hand monitor for PLAYER_ than screen will pop up for full screen, otherwise its PIP
		4. _canSwitchNvg [bool]
		5. _canSwitchTi [bool]
		6. _canSwitchTurret [bool]
		7. _canZoom [bool]
		8. _canFullScreen [bool]
		9. _canConnectDrone [bool] - if it can connect to currently feeding drone
		10. _canFix [bool] - if has "fix feed" action
		11. _canTurnOffLocal [bool] - if has "turn off/on local" action
*/

#include "defines.hpp"

params [
	["_monitor", objNull], 
	["_sides", [side PLAYER_]],
	["_isHandMonitorDisplay", false],
	["_canSwitchNvg", true],
	["_canSwitchTi", true],
	["_canSwitchTurret", true],
	["_canZoom", true],
	["_canFullScreen", true],
	["_canConnectDrone", true],
	["_canFix", true],
	["_canTurnOffLocal", true]
];

if (isNil "_monitor") exitWith {false};

private _reset = if (isNil "_reset") then {false} else {_reset};

if (_monitor isEqualType []) exitWith {
	private _mainArgs = [_sides, _isHandMonitorDisplay, _canSwitchNvg, _canSwitchTi, _canSwitchTurret, _canZoom, _canFullScreen, _canConnectDrone, _canFix, _canTurnOffLocal];
	_monitor apply {
		if (isNil "_x") then {continue};
		if (_x isEqualType []) then {
			private _args = +_x;
			for "_i" from 1 to (count _mainArgs) do {
				private _val = _args#_i;
				if (isNil "_val") then {
					_args set [_i, (_mainArgs select (_i - 1))];
				};
			};
			_args call CFM_fnc_setMonitor;
		} else {
			private _args = [_x] + _mainArgs;
			_args call CFM_fnc_setMonitor;
		};
	};
};
if !(IS_OBJ(_monitor)) exitWith {false};

#ifdef SET_MON_OP_REMOTE_EXEC
	// for JIP sync
	if !(isServer) exitWith {false};

	[_this, {
	_this NEW_OBJINSTANCE("Monitor");
	}, 0, true, true] call CFM_fnc_remoteExec;
#endif 
#ifndef SET_MON_OP_REMOTE_EXEC
	_this NEW_OBJINSTANCE("Monitor");
#endif 