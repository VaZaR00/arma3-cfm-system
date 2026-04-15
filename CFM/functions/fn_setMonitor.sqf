/*
	CFM_fnc_setMonitor

	Sets obj as monitor
*/

#include "defines.hpp"

params [
	["_monitor", objNull], 
	["_sides", [side player]],
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

_this NEW_OBJINSTANCE("Monitor");

true