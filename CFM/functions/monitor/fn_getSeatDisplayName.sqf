/*
    Function: CFM_fnc_getSeatDisplayName
    Author: Vazar
    Description: Resolves localized display name from vehicle config for a seatKey (driver, turret_[...], cargo_N).
*/

#include "defines.hpp"

params [
	["_veh", objNull],
	["_seatKey", ""]
];

if (!(IS_OBJ(_veh)) || {!(_seatKey isEqualType "")} || {_seatKey isEqualTo ""}) exitWith {""};

private _fnc_resolveLoc = {
	params [["_str", ""]];
	_str = trim _str;
	if (_str isEqualTo "") exitWith {""};
	if ((_str select [0, 1]) isEqualTo "$") then {
		private _key = _str select [1];
		if (isLocalized _key) then {localize _key} else {_str};
	} else {
		if (isLocalized _str) then {localize _str} else {_str};
	};
};

private _fnc_getRoleFallback = {
	params [["_roleName", ""]];
	switch (toLower _roleName) do {
		case "driver": {
			if (_veh isKindOf "Air") then {
				if (isLocalized "STR_POSITION_PILOT") then {localize "STR_POSITION_PILOT"} else {CFM_STR_PILOT};
			} else {
				if (isLocalized "STR_POSITION_DRIVER") then {localize "STR_POSITION_DRIVER"} else {CFM_STR_DRIVER};
			};
		};
		case "commander": {
			if (isLocalized "STR_POSITION_COMMANDER") then {localize "STR_POSITION_COMMANDER"} else {"Commander"};
		};
		case "gunner": {
			if (isLocalized "STR_POSITION_GUNNER") then {localize "STR_POSITION_GUNNER"} else {CFM_STR_GUNNER};
		};
		case "cargo": {
			if (isLocalized "STR_POSITION_CARGO") then {localize "STR_POSITION_CARGO"} else {"Cargo"};
		};
		default {""};
	};
};

private _keyLower = toLower _seatKey;

if (_keyLower isEqualTo "driver") exitWith {
	private _driverCrew = (fullCrew [_veh, "driver", true]) param [0, []];
	private _posName = [_driverCrew param [6, ""]] call _fnc_resolveLoc;
	if !(_posName isEqualTo "") exitWith {_posName};

	private _fallback = ["driver"] call _fnc_getRoleFallback;
	if !(_fallback isEqualTo "") exitWith {_fallback};
	_seatKey
};

if ((_keyLower select [0, 7]) isEqualTo "turret_") exitWith {
	private _turretPath = parseSimpleArray (_seatKey select [7]);
	if (isNil "_turretPath" || {!(_turretPath isEqualType [])} || {_turretPath isEqualTo []}) exitWith {_seatKey};

	private _turretCfg = [_veh, _turretPath] call BIS_fnc_turretConfig;
	private _cfgName = if (!isNull _turretCfg) then {
		[getText (_turretCfg >> "gunnerName")] call _fnc_resolveLoc
	} else {""};
	if !(_cfgName isEqualTo "") exitWith {_cfgName};

	private _fullCrew = fullCrew [_veh, "", true];
	private _crewEntry = (_fullCrew select {(_x select 3) isEqualTo _turretPath}) param [0, []];
	private _posName = [_crewEntry param [6, ""]] call _fnc_resolveLoc;
	if !(_posName isEqualTo "") exitWith {_posName};

	private _role = toLower (_crewEntry param [1, ""]);
	private _fallback = [_role] call _fnc_getRoleFallback;
	if (_fallback isEqualTo "" && {_crewEntry param [4, false]}) then {
		_fallback = ["cargo"] call _fnc_getRoleFallback;
	};
	if !(_fallback isEqualTo "") exitWith {_fallback};
	_seatKey
};

if ((_keyLower select [0, 6]) isEqualTo "cargo_") exitWith {
	private _cargoIdx = parseNumber (_seatKey select [6]);
	private _cargoCrew = (fullCrew [_veh, "cargo", true]) select {(_x select 3) isEqualTo []};
	private _crewEntry = (_cargoCrew select {(_x select 2) isEqualTo _cargoIdx}) param [0, []];
	private _posName = [_crewEntry param [6, ""]] call _fnc_resolveLoc;
	if !(_posName isEqualTo "") exitWith {_posName};

	private _baseCargo = ["cargo"] call _fnc_getRoleFallback;
	if (_baseCargo isEqualTo "") exitWith {_seatKey};
	if ((count _cargoCrew) > 1) exitWith {
		format ["%1 #%2", _baseCargo, _cargoIdx + 1]
	};
	_baseCargo
};

private _roleFallback = [_keyLower] call _fnc_getRoleFallback;
if !(_roleFallback isEqualTo "") exitWith {_roleFallback};

_seatKey
