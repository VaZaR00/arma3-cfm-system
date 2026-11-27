/*
    Function: CFM_fnc_resolveDisplayConfig
    Author: Vazar & Gemini
    Description:
        Resolves a UI display/HUD class name, explicit config path string (e.g. "RscTitles >> MyHud"),
        or Config reference against missionConfigFile and configFile (Root, RscTitles, RscInGameUI),
        and identifies whether it is already a native CFM display config.
    Parameters:
        0: _classSpec [String | Config] - Display class name, config path string, or Config entry.
    Returns:
        [Array] - [_resolvedCfg, _sourceType, _configRootName, _configPathArray, _isNativeCfm]
*/

#include "defines.hpp"

params [["_classSpec", "", ["", configNull]]];

private _emptyResult = [configNull, "", "", [], false];

private _fnc_inferSourceType = {
	params ["_pathArr"];
	if (_pathArr isEqualTo []) exitWith {"Root"};
	private _first = toLower (_pathArr select 0);
	if (_first isEqualTo "rsctitles") exitWith {"RscTitles"};
	if (_first isEqualTo "rscingameui") exitWith {"RscInGameUI"};
	"Root"
};

private _fnc_isNativeCfm = {
	params ["_cfg", "_srcType"];
	if !(_srcType isEqualTo "Root") exitWith {false};
	private _r2tCfg = _cfg >> "controlsBackground" >> "R2TPicture";
	if !(isClass _r2tCfg) exitWith {false};
	private _idcCfg = _r2tCfg >> "idc";
	if (isNumber _idcCfg) exitWith {(getNumber _idcCfg) isEqualTo 1488};
	if (isText _idcCfg) exitWith {(parseNumber (getText _idcCfg)) isEqualTo 1488};
	false
};

if (_classSpec isEqualType configNull) exitWith {
	if (isNull _classSpec || {!(isClass _classSpec)}) exitWith {_emptyResult};
	private _hier = configHierarchy _classSpec;
	if (_hier isEqualTo []) exitWith {_emptyResult};
	private _rootCfg = _hier select 0;
	private _rootName = if (_rootCfg isEqualTo missionConfigFile) then {
		"missionConfigFile"
	} else {
		if (_rootCfg isEqualTo configFile) then {"configFile"} else {""}
	};
	if (_rootName isEqualTo "") exitWith {_emptyResult};
	private _pathArr = (_hier select [1]) apply {configName _x};
	private _srcType = [_pathArr] call _fnc_inferSourceType;
	private _native = [_classSpec, _srcType] call _fnc_isNativeCfm;
	[_classSpec, _srcType, _rootName, _pathArr, _native]
};

if !(_classSpec isEqualType "") exitWith {_emptyResult};
private _spec = trim _classSpec;
if (_spec isEqualTo "") exitWith {_emptyResult};

if ((_spec find ">>") >= 0) exitWith {
	private _rawParts = _spec splitString ">";
	private _parts = [];
	{
		private _p = trim _x;
		if !(_p isEqualTo "") then {
			_parts pushBack _p;
		};
	} forEach _rawParts;
	if (_parts isEqualTo []) exitWith {_emptyResult};

	private _forcedRoot = "";
	private _firstLow = toLower (_parts select 0);
	if (_firstLow isEqualTo "missionconfigfile") then {
		_forcedRoot = "missionConfigFile";
		_parts deleteAt 0;
	} else {
		if (_firstLow isEqualTo "configfile") then {
			_forcedRoot = "configFile";
			_parts deleteAt 0;
		};
	};
	if (_parts isEqualTo []) exitWith {_emptyResult};

	private _rootsToTry = if (_forcedRoot isEqualTo "") then {
		[[missionConfigFile, "missionConfigFile"], [configFile, "configFile"]]
	} else {
		if (_forcedRoot isEqualTo "missionConfigFile") then {
			[[missionConfigFile, "missionConfigFile"]]
		} else {
			[[configFile, "configFile"]]
		}
	};

	private _found = _emptyResult;
	{
		_x params ["_curCfg", "_curRootName"];
		private _walkedNames = [];
		private _valid = true;
		{
			_curCfg = _curCfg >> _x;
			if (isNull _curCfg) exitWith {_valid = false;};
			_walkedNames pushBack (configName _curCfg);
		} forEach _parts;
		if (_valid && {isClass _curCfg}) exitWith {
			private _srcType = [_walkedNames] call _fnc_inferSourceType;
			private _native = [_curCfg, _srcType] call _fnc_isNativeCfm;
			_found = [_curCfg, _srcType, _curRootName, _walkedNames, _native];
		};
	} forEach _rootsToTry;

	_found
};

private _candidates = [
	[missionConfigFile >> _spec, "Root", "missionConfigFile"],
	[missionConfigFile >> "RscTitles" >> _spec, "RscTitles", "missionConfigFile"],
	[configFile >> _spec, "Root", "configFile"],
	[configFile >> "RscTitles" >> _spec, "RscTitles", "configFile"],
	[configFile >> "RscInGameUI" >> _spec, "RscInGameUI", "configFile"]
];

private _result = _emptyResult;
{
	_x params ["_cfg", "_srcType", "_rootName"];
	if (isClass _cfg) exitWith {
		private _cfgName = configName _cfg;
		private _pathArr = if (_srcType isEqualTo "Root") then {
			[_cfgName]
		} else {
			[_srcType, _cfgName]
		};
		private _native = [_cfg, _srcType] call _fnc_isNativeCfm;
		_result = [_cfg, _srcType, _rootName, _pathArr, _native];
	};
} forEach _candidates;

_result
