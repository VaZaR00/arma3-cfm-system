/*
    Function: CFM_fnc_indexAddonHudConfigs
    Author: Vazar & Gemini
    Description:
        Scans third-party addons' RscTitles and root display classes in configFile once,
        filtering out vanilla Bohemia configs, CFM's own displays, and interactive menus/dialogs,
        and builds an index keyed by addon name and mod folder for fast UAV HUD auto-discovery.
    Returns:
        [Array] - [_byAddonMap, _byModMap]
*/

#include "defines.hpp"

private _cached = UI_CACHE_NAMESPACE getVariable "CFM_addonHudIndexCache";
if (!isNil "_cached" && {_cached isEqualType []} && {(count _cached) isEqualTo 2}) exitWith {_cached};

private _byAddonMap = createHashMap;
private _byModMap = createHashMap;

private _vanillaMods = [
	"", "a3", "curator", "kart", "heli", "mark", "expansion",
	"jets", "orange", "argo", "tacops", "tank", "enoch", "contact", "aow"
];

private _fnc_getCfgNumQuick = {
	params ["_cfg", "_propName", ["_def", 0]];
	private _prop = _cfg >> _propName;
	if (isNull _prop) exitWith {_def};
	if (isNumber _prop) exitWith {getNumber _prop};
	if (isText _prop) exitWith {
		private _t = trim (getText _prop);
		if (_t regexMatch "^[+-]?[0-9]+(?:\.[0-9]+)?$/") exitWith {parseNumber _t};
		_def
	};
	_def
};

private _fnc_hasInteractiveControls = {
	params ["_dispCfg"];
	private _hasInteractive = false;
	{
		private _prop = _dispCfg >> _x;
		if (isArray _prop) then {
			private _hasSub = isClass _prop;
			{
				if (_x isEqualType "") then {
					private _sub = _dispCfg >> _x;
					if (!(isClass _sub) && {_hasSub}) then {_sub = _prop >> _x;};
					if (isClass _sub) then {
						private _cType = [_sub, "type", 0] call _fnc_getCfgNumQuick;
						if (_cType in DYN_HUD_INTERACTIVE_CTRL_TYPES) exitWith {_hasInteractive = true;};
					};
				};
				if (_hasInteractive) exitWith {};
			} forEach (getArray _prop);
		} else {
			if (isClass _prop) then {
				{
					private _cType = [_x, "type", 0] call _fnc_getCfgNumQuick;
					if (_cType in DYN_HUD_INTERACTIVE_CTRL_TYPES) exitWith {_hasInteractive = true;};
				} forEach (configProperties [_prop, "isClass _x", true]);
			};
		};
		if (_hasInteractive) exitWith {};
	} forEach ["controls", "controlsBackground"];
	_hasInteractive
};

private _fnc_scanContainer = {
	params ["_containerCfg", "_prefixPath"];
	if (isNull _containerCfg) exitWith {};
	{
		private _clsCfg = _x;
		private _clsName = configName _clsCfg;
		private _lowName = toLower _clsName;

		if (
			((_lowName select [0, 3]) isEqualTo "cfm") ||
			{(_lowName select [0, 6]) isEqualTo "rsccfm"} ||
			{(_lowName select [0, 13]) isEqualTo "rscdisplaycfm"} ||
			{_lowName in ["rscdisplaymaindisplaycfm", "rscdisplayr2tdisplaycfm", "rscdisplayuidisplaycfm"]}
		) then {
			continue;
		};

		private _modDir = toLower (configSourceMod _clsCfg);
		if (_modDir in _vanillaMods) then {continue};

		private _addons = configSourceAddonList _clsCfg;
		private _isCfmAddon = false;
		{
			if ((toLower _x) in ["cfm", "cfm_modules", "cfm_efl", "cfm_oop"]) exitWith {_isCfmAddon = true;};
		} forEach _addons;
		if (_isCfmAddon) then {continue};

		if (
			!(isClass (_clsCfg >> "controls")) &&
			{!(isArray (_clsCfg >> "controls"))} &&
			{!(isClass (_clsCfg >> "controlsBackground"))} &&
			{!(isArray (_clsCfg >> "controlsBackground"))}
		) then {
			continue;
		};

		if ((_lowName select [0, 10]) isEqualTo "rscdisplay" && {!("hud" in _lowName) && {!("optic" in _lowName)} && {!("uav" in _lowName)}}) then {
			continue;
		};

		if ([_clsCfg] call _fnc_hasInteractiveControls) then {continue};

		private _spec = if (_prefixPath isEqualTo "") then {_clsName} else {format ["%1 >> %2", _prefixPath, _clsName]};

		{
			private _lowAddon = toLower _x;
			private _arr = _byAddonMap getOrDefault [_lowAddon, []];
			_arr pushBackUnique _spec;
			_byAddonMap set [_lowAddon, _arr];
		} forEach _addons;

		if !(_modDir isEqualTo "") then {
			private _mArr = _byModMap getOrDefault [_modDir, []];
			_mArr pushBackUnique _spec;
			_byModMap set [_modDir, _mArr];
		};
	} forEach (configProperties [_containerCfg, "isClass _x", false]);
};

[configFile >> "RscTitles", "RscTitles"] call _fnc_scanContainer;
[configFile, ""] call _fnc_scanContainer;

private _result = [_byAddonMap, _byModMap];
UI_CACHE_NAMESPACE setVariable ["CFM_addonHudIndexCache", _result];

_result
