/*
    Function: CFM_fnc_detectOperatorHudConfig
    Author: Vazar & Gemini
    Description:
        Automatically discovers the appropriate HUD display class and callbacks for an operator
        and turret using: 1) registered CFM_hudPresets, 2) addon RscTitles/Root config index,
        3) vehicle/turret CfgVehicles optics config (turretInfoType, PilotCamera, unitInfoType).
    Parameters:
        0: _operator [Object] - Operator entity (optional when _opClass provided).
        1: _turret [Number | Array] - Turret index or path (default -1).
        2: _opClass [String] - Operator CfgVehicles class name (default "").
        3: _isDrone [Boolean] - Whether operator is a UAV/drone feed (default false).
        4: _presetsOnly [Boolean] - Only check user-registered presets (default false).
    Returns:
        [Array] - [_displayClass, _updateFunc, _initFunc] or [_displayClass, _updateFunc, _initFunc, _customBindings], or [] if none.
*/

#include "defines.hpp"

params [
	["_operator", objNull],
	["_turret", -1],
	["_opClass", ""],
	["_isDrone", false],
	["_presetsOnly", false]
];

private _vehClass = if (IS_OBJ(_operator)) then {
	typeOf _operator
} else {
	if (IS_STR(_opClass)) then {
		private _cfgTest = configFile >> "CfgVehicles" >> _opClass;
		if (isClass _cfgTest) then {configName _cfgTest} else {_opClass}
	} else {
		""
	}
};

if (_vehClass isEqualTo "") exitWith {[]};

private _lowVehClass = toLower _vehClass;
private _turretIdx = if (_turret isEqualType []) then {TURRET_INDEX(_turret)} else {_turret};

// Priority 1: User-registered HUD presets
private _matchedPreset = [];
private _presets = missionNamespace getVariable ["CFM_hudPresets", []];
if !(_presets isEqualTo []) then {
	private _exactPreset = [];
	private _wildPreset = [];
	// Pass 1: exact class / isKindOf
	{
		_x params ["_pat", "_pTurr", "_pDisp", "_pUpd", "_pInit", "_pIsPattern", ["_pBindings", []]];
		if (!_pIsPattern && {(_lowVehClass isEqualTo _pat) || {_vehClass isKindOf _pat}}) then {
			if (_pTurr isEqualTo _turretIdx) exitWith {_exactPreset = [_pDisp, _pUpd, _pInit, _pBindings];};
			if (_pTurr isEqualTo -2 && {_wildPreset isEqualTo []}) then {_wildPreset = [_pDisp, _pUpd, _pInit, _pBindings];};
		};
		if !(_exactPreset isEqualTo []) exitWith {};
	} forEach _presets;

	// Pass 2: pattern substring
	if (_exactPreset isEqualTo [] && {_wildPreset isEqualTo []}) then {
		{
			_x params ["_pat", "_pTurr", "_pDisp", "_pUpd", "_pInit", "_pIsPattern", ["_pBindings", []]];
			if (_pIsPattern && {_pat in _lowVehClass}) then {
				if (_pTurr isEqualTo _turretIdx) exitWith {_exactPreset = [_pDisp, _pUpd, _pInit, _pBindings];};
				if (_pTurr isEqualTo -2 && {_wildPreset isEqualTo []}) then {_wildPreset = [_pDisp, _pUpd, _pInit, _pBindings];};
			};
			if !(_exactPreset isEqualTo []) exitWith {};
		} forEach _presets;
	};

	if !(_exactPreset isEqualTo []) then {
		_matchedPreset = _exactPreset;
	} else {
		if !(_wildPreset isEqualTo []) then {
			_matchedPreset = _wildPreset;
		};
	};
};
if !(_matchedPreset isEqualTo []) exitWith {_matchedPreset};

if (_presetsOnly) exitWith {[]};

private _cache = missionNamespace getVariable ["CFM_detectedOperatorHudCache", createHashMap];
private _cacheKey = format ["%1:%2:%3", _lowVehClass, _turretIdx, _isDrone];
if (_cacheKey in _cache) exitWith {
	+(_cache get _cacheKey)
};

if !(_isDrone) exitWith {
	_cache set [_cacheKey, []];
	missionNamespace setVariable ["CFM_detectedOperatorHudCache", _cache];
	[]
};

private _vehCfg = configFile >> "CfgVehicles" >> _vehClass;
if !(isClass _vehCfg) exitWith {[]};

private _fnc_isRenderableSpec = {
	params ["_spec"];
	if (_spec isEqualTo "") exitWith {false};
	private _resolved = ([_spec] call CFM_fnc_resolveDisplayConfig) select 0;
	if (isNull _resolved) exitWith {false};
	private _bp = [_spec] call CFM_fnc_parseDynamicDisplayConfig;
	!((_bp getOrDefault ["bgNodes", []]) isEqualTo []) || {!((_bp getOrDefault ["fgNodes", []]) isEqualTo [])}
};

private _detectedClass = "";

// Priority 2: Addon RscTitles / Root index matching
(call CFM_fnc_indexAddonHudConfigs) params ["_byAddonMap", "_byModMap"];
private _genericTokens = ["blu", "opf", "ind", "civ", "uav", "drone", "base", "af", "unarmed", "armed"];
private _vehTokens = ((_lowVehClass splitString "_") select {(count _x) >= 3 && {!(_x in _genericTokens)}});

private _candSpecs = [];
{
	private _arr = _byAddonMap getOrDefault [toLower _x, []];
	{
		_candSpecs pushBackUnique _x;
	} forEach _arr;
} forEach (configSourceAddonList _vehCfg);

if (_candSpecs isEqualTo [] && {!(_vehTokens isEqualTo [])}) then {
	private _modDir = toLower (configSourceMod _vehCfg);
	if !(_modDir isEqualTo "") then {
		private _modCands = _byModMap getOrDefault [_modDir, []];
		{
			private _lowC = toLower _x;
			if ((_vehTokens findIf {_x in _lowC}) >= 0) then {
				_candSpecs pushBackUnique _x;
			};
		} forEach _modCands;
	};
};

if !(_candSpecs isEqualTo []) then {
	private _bestScore = -1;
	private _bestCand = "";
	{
		private _cand = _x;
		private _lowC = toLower _cand;
		private _score = 0;

		if (_turretIdx < 0) then {
			if (("driver" in _lowC) || {"pilot" in _lowC}) then {_score = _score + 50;};
			if (("gunner" in _lowC) || {"turret" in _lowC}) then {_score = _score - 100;};
		} else {
			if (("gunner" in _lowC) || {"turret" in _lowC} || {"optic" in _lowC}) then {_score = _score + 50;};
			if (("driver" in _lowC) || {"pilot" in _lowC}) then {_score = _score - 100;};
		};

		{
			if (_x in _lowC) then {_score = _score + 20;};
		} forEach _vehTokens;

		if (("hud" in _lowC) || {"interface" in _lowC} || {"overlay" in _lowC}) then {
			_score = _score + 10;
		};

		if (_score >= 0 && {_score > _bestScore} && {[_cand] call _fnc_isRenderableSpec}) then {
			_bestScore = _score;
			_bestCand = _cand;
		};
	} forEach _candSpecs;

	if !(_bestCand isEqualTo "") then {
		_detectedClass = _bestCand;
	};
};

// Priority 3: CfgVehicles turretInfoType / PilotCamera / driverWeaponsInfoType / unitInfoType
if (_detectedClass isEqualTo "") then {
	private _infoCandidates = [];
	if (_turretIdx >= 0) then {
		private _turrCfg = if (IS_OBJ(_operator)) then {
			[_operator, [_turretIdx]] call BIS_fnc_turretConfig
		} else {
			private _tClasses = configProperties [_vehCfg >> "Turrets", "isClass _x", true];
			_tClasses param [_turretIdx, configNull]
		};
		if (isClass _turrCfg) then {
			private _tInfo = getText (_turrCfg >> "turretInfoType");
			if !(_tInfo isEqualTo "") then {_infoCandidates pushBack _tInfo;};
		};
	} else {
		private _pCamInfo = getText (_vehCfg >> "PilotCamera" >> "turretInfoType");
		if !(_pCamInfo isEqualTo "") then {_infoCandidates pushBack _pCamInfo;};

		private _dWeapInfo = getText (_vehCfg >> "driverWeaponsInfoType");
		if !(_dWeapInfo isEqualTo "") then {_infoCandidates pushBack _dWeapInfo;};

		private _dOptInfo = getText (_vehCfg >> "driverOpticsInfoType");
		if !(_dOptInfo isEqualTo "") then {_infoCandidates pushBack _dOptInfo;};

		private _uInfo = getText (_vehCfg >> "unitInfoType");
		private _genericUnitInfos = [
			"rscunitinfo", "rscunitinfoair", "rscunitinfotank", "rscunitinfocar",
			"rscunitinfoship", "rscunitinfosoldier", "rscunitinfoparachute", "rscunitinfonoweapon"
		];
		if (!(_uInfo isEqualTo "") && {!((toLower _uInfo) in _genericUnitInfos)}) then {
			_infoCandidates pushBack _uInfo;
		};
	};

	{
		if ([_x] call _fnc_isRenderableSpec) exitWith {
			_detectedClass = _x;
		};
	} forEach _infoCandidates;
};

private _result = if !(_detectedClass isEqualTo "") then {
	[_detectedClass, MGVAR ["CFM_fnc_updateDynamicHud", {}], MGVAR ["CFM_fnc_initDynamicHud", {}]]
} else {
	[]
};

_cache set [_cacheKey, _result];
missionNamespace setVariable ["CFM_detectedOperatorHudCache", _cache];

_result
