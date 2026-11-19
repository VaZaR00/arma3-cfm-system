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
		6. _seatKeys [String / Array] - seat keys (empty/DEFAULT = driver/gunner/commander, "ALL" = all seats, +[...]/-[...]/![seat,texSel] modifiers, shared PiP [["cargo_0","cargo_1"], -1] or controller-only [["cargo_0","cargo_1"], -1, "cargo_0"], or explicit keys e.g. '["driver", 0]')
		7. _isVehSeatTablet [bool / -1] - whether object uses vehicle seat tablet logic (-1 = auto detect)
		8. _canSwitchNvg [bool]
		9. _canSwitchTi [bool]
		10. _canSwitchTurret [bool]
		11. _canZoom [bool]
		12. _canFullScreen [bool]
		13. _canConnectDrone [bool] - if it can connect to currently feeding drone
		14. _canFix [bool] - if has "fix feed" action
		15. _canTurnOffLocal [bool] - if has "turn off/on local" action
		16. _canSetPassword [bool] - if monitor can have a password set
		17. _screenResolution [string / Array[number, number]] - monitor screen resolution or aspect ratio
		18. _textureSelections [string / number / Array[number]] - texture selection indices (e.g. "0, 1, 2")
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
	["_monitor", objNull],
	["_sides", []],
	["_allowedOperators", []],
	["_allowedOperatorsTypes", []],
	["_isHandMonitorDisplay", false],
	["_seatKeys", ""],
	["_isVehSeatTabletSet", -1],
	["_canSwitchNvg", true],
	["_canSwitchTi", true],
	["_canSwitchTurret", true],
	["_canZoom", true],
	["_canFullScreen", true],
	["_canConnectDrone", true],
	["_canFix", true],
	["_canTurnOffLocal", true],
	["_canSetPassword", true],
	["_screenResolution", ""],
	["_textureSelections", ""]
];

if (isNil "_monitor") exitWith {false};

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

// Hand monitors are strictly local
if (_isPlayer && !_local) exitWith {};

private _commonArgs = [
	_sides,
	_allowedOperators,
	_allowedOperatorsTypes,
	_isHandMonitorDisplay,
	_canSwitchNvg,
	_canSwitchTi,
	_canSwitchTurret,
	_canZoom,
	_canFullScreen,
	_canConnectDrone,
	_canFix,
	_canTurnOffLocal,
	_canSetPassword,
	_screenResolution
];

if (_isPlayer && _local) exitWith {
	waitUntil {
		sleep 2;
		!(IS_OBJ(_monitor)) || {_monitor call CFM_fnc_hasUAVterminal}
	};
	if !(IS_OBJ(_monitor)) exitWith {false};
	private _instanceSpecs = [_monitor, "", "", false, true] call CFM_fnc_parseMonitorSelections;
	if !(_monitor getVariable ["CFM_isMonitorHostCreated", false]) then {
		[_monitor, [true]] NEW_OBJINSTANCE("MonitorHost");
	};
	["addInstances", [_instanceSpecs, _commonArgs, true]] CALL_OBJCLASS("MonitorHost", _monitor);
};

#ifdef SET_MON_OP_REMOTE_EXEC
// for JIP sync
if !(isServer) exitWith {false};
#endif

private _isVehSeatTablet = if (_isVehSeatTabletSet isEqualType true) then {
	_isVehSeatTabletSet
} else {
	(_monitor isKindOf "LandVehicle") || {(_monitor isKindOf "Air")} || {(_monitor isKindOf "Ship")}
};

private _instanceSpecs = [_monitor, _textureSelections, _seatKeys, _isVehSeatTablet, false] call CFM_fnc_parseMonitorSelections;
if (_instanceSpecs isEqualTo []) exitWith {false};

private _eventArgs = [_monitor, _instanceSpecs, _commonArgs];

#ifdef SET_MON_OP_REMOTE_EXEC
	["CFM_newMonitorInstance", _eventArgs, true, _monitor] call CFM_fnc_remoteEvent;
#else
	if !(_monitor getVariable ["CFM_isMonitorHostCreated", false]) then {
		[_monitor, [false]] NEW_OBJINSTANCE("MonitorHost");
	};
	["addInstances", [_instanceSpecs, _commonArgs, false]] CALL_OBJCLASS("MonitorHost", _monitor);
#endif 
