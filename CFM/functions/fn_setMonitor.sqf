/*
	Name: CFM_fnc_setMonitor

	Call: spawn

	Description: 
		Sets obj as monitor

	Return: true os succes, false or any if not

	Arguments:
		1. _monitor [object]
		2. _sides [Array[side], side] - defines which operators sides it have access to
		3. _allowedOperators [Array[object], object] - defines which operators it have access to
		4. _allowedOperatorsTypes [Array[string], string] - defines which operators it have access to
		5. _isHandMonitorDisplay [bool] - if its hand monitor for PLAYER_ than screen will pop up for full screen, otherwise its PIP
		6. _canSwitchNvg [bool]
		7. _canSwitchTi [bool]
		8. _canSwitchTurret [bool]
		9. _canZoom [bool]
		10. _canFullScreen [bool]
		11. _canConnectDrone [bool] - if it can connect to currently feeding drone
		12. _canFix [bool] - if has "fix feed" action
		13. _canTurnOffLocal [bool] - if has "turn off/on local" action
*/

#include "defines.hpp"

if !(canSuspend) exitWith {
	_this spawn CFM_fnc_setMonitor;
};
waitUntil { !(isNil "CFM_inited") };

if !(_this isEqualType []) then {
	_this = [_this];
};

params [
	["_monitor", objNull]
];

if (isNil "_monitor") exitWith {false};

private _reset = if (isNil "_reset") then {false} else {_reset};

if (_monitor isEqualType []) exitWith {
	private _mainArgs = _this select [1, count _this];
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

private _isPlayer = (_monitor isEqualTo PLAYER_) || {(_monitor isKindOf "Man")};
private _local = (_monitor isEqualTo PLAYER_);

// Hand monitors are local
if (_isPlayer && !_local) exitWith {};

private _mainArgs = _this select [1, count _this];
_this = [_monitor, _mainArgs];

if (_isPlayer && _local) exitWith {
	_this SPAWN_NEW_OBJINSTANCE("Monitor");
};

#ifdef SET_MON_OP_REMOTE_EXEC
// for JIP sync
if !(isServer) exitWith {false};
#endif

#ifdef SET_MON_OP_REMOTE_EXEC
	[_this, {
		waitUntil { sleep 1; !(isNil "CFM_inited") };
		_this SPAWN_NEW_OBJINSTANCE("Monitor");
	}, 0, true, false] call CFM_fnc_remoteExec;
#endif 
#ifndef SET_MON_OP_REMOTE_EXEC
	_this SPAWN_NEW_OBJINSTANCE("Monitor");
#endif 