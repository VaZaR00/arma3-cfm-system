/*
    Function: CFM_fnc_registerHudPreset
    Author: Vazar & Gemini
    Description:
        Registers or overrides a custom HUD preset mapping for a vehicle class, parent class,
        or substring pattern (optionally per turret index) using either a custom update function
        or a declarative array of widget bindings for CFM_fnc_updateDynamicHud.
    Parameters:
        0: _classOrPattern [String] - Vehicle classname (or substring when _isPattern is true).
        1: _turretIndex [Number | Array] - Turret index/path, or -2 for all turrets (default -2).
        2: _displayClass [String] - HUD display class name or config path (e.g. "RscTitles >> MyHud").
        3: _updateFuncOrBindings [Code | String | Array] - Update CODE, function name, or declarative bindings array (default {}).
        4: _initFunc [Code | String] - Optional custom init CODE or function name (default {}).
        5: _isPattern [Boolean] - If true, _classOrPattern matches as substring in typeOf (default false).
    Returns:
        [Boolean] - true if registered, false on invalid arguments.
*/

#include "defines.hpp"

params [
	["_classOrPattern", "", [""]],
	["_turretIndex", -2, [0, []]],
	["_displayClass", "", [""]],
	["_updateFuncOrBindings", {}, [{}, "", []]],
	["_initFunc", {}, [{}, ""]],
	["_isPattern", false, [false]]
];

_classOrPattern = trim _classOrPattern;
_displayClass = trim _displayClass;
if (_classOrPattern isEqualTo "" || {_displayClass isEqualTo ""}) exitWith {false};

private _turretIdx = if (_turretIndex isEqualType []) then {TURRET_INDEX(_turretIndex)} else {_turretIndex};
private _lowKey = toLower _classOrPattern;

private _customBindings = [];
private _updFunc = {};
if (_updateFuncOrBindings isEqualType []) then {
	_customBindings = +_updateFuncOrBindings;
	_updFunc = MGVAR ["CFM_fnc_updateDynamicHud", {}];
} else {
	if (_updateFuncOrBindings isEqualType "") then {
		_updFunc = MGVAR [_updateFuncOrBindings, MGVAR ["CFM_fnc_updateDynamicHud", {}]];
	} else {
		_updFunc = if (_updateFuncOrBindings isEqualTo {}) then {
			MGVAR ["CFM_fnc_updateDynamicHud", {}]
		} else {
			_updateFuncOrBindings
		};
	};
};

private _resolvedInitFunc = if (_initFunc isEqualType "") then {
	MGVAR [_initFunc, MGVAR ["CFM_fnc_initDynamicHud", {}]]
} else {
	if (_initFunc isEqualTo {}) then {
		MGVAR ["CFM_fnc_initDynamicHud", {}]
	} else {
		_initFunc
	}
};

private _presets = missionNamespace getVariable ["CFM_hudPresets", []];
private _entry = [_lowKey, _turretIdx, _displayClass, _updFunc, _resolvedInitFunc, _isPattern, _customBindings];
private _existingIdx = _presets findIf {
	((_x select 0) isEqualTo _lowKey) &&
	{(_x select 1) isEqualTo _turretIdx} &&
	{(_x select 5) isEqualTo _isPattern}
};

if (_existingIdx >= 0) then {
	_presets set [_existingIdx, _entry];
} else {
	_presets pushBack _entry;
};

missionNamespace setVariable ["CFM_hudPresets", _presets];
missionNamespace setVariable ["CFM_detectedOperatorHudCache", nil];

true
