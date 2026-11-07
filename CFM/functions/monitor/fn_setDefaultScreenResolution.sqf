/*
    Function: CFM_fnc_setDefaultScreenResolution
    Author: Vazar
    Description:
        Sets or overrides default screen resolution preset for a class, array of classes/patterns, or monitor object.
*/

#include "defines.hpp"

params [["_classOrMonitor", ""], ["_resolution", ""]];

if (isNil "CFM_initDefScreenResolutionsSet") then {
	0 call CFM_fnc_setupDefScreenResolutions;
};

private _parsedRes = [_resolution] call CFM_fnc_parseScreenResolution;
if (_parsedRes isEqualTo []) exitWith {false};

if (_classOrMonitor isEqualType objNull) exitWith {
	if !(IS_OBJ(_classOrMonitor)) exitWith {false};
	[_classOrMonitor, _parsedRes] call CFM_fnc_setScreenResolution
};

private _resSet = missionNamespace getVariable ["CFM_classesScreenResolutionSet", createHashMap];
private _patternRules = missionNamespace getVariable ["CFM_screenResolutionPatterns", []];

if (_classOrMonitor isEqualType "") exitWith {
	private _clsLower = toLower _classOrMonitor;
	_resSet set [_clsLower, +_parsedRes];
	_patternRules pushBack [[_clsLower], +_parsedRes];
	true
};

if (_classOrMonitor isEqualType []) exitWith {
	private _patterns = (_classOrMonitor select {_x isEqualType ""}) apply {toLower _x};
	if (_patterns isEqualTo []) exitWith {false};
	_patternRules pushBack [_patterns, +_parsedRes];
	{
		_resSet set [_x, +_parsedRes];
	} forEach _patterns;
	true
};

false
