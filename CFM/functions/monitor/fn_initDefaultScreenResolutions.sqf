/*
    Function: CFM_fnc_initDefaultScreenResolutions
    Author: Vazar
    Description:
        Initializes default screen resolution presets for monitor classes and class types.
*/

#include "defines.hpp"

private _resSet = parsingNamespace getVariable ["CFM_classesScreenResolutionSet", createHashMap];
private _patternRules = parsingNamespace getVariable ["CFM_screenResolutionPatterns", []];

private _allConfigClasses = ("true" configClasses (configFile >> "CfgVehicles")) apply {toLower (configName _x)};

// Default screen resolution for monitors not matching any preset is [512, 512] ("1:1 512")
private _defaults = [
	/*
		[
			class:
				1. string (exact classname or parent class)
				2. [string, string, ...] (class substrings / types)
			resolution:
				1. "w:h" (e.g. "1:1", "4:3", "16:9")
				2. "w:h width" (e.g. "1:1 500", "4:3 600")
				3. "WxH" (e.g. "700x500")
				4. [width, height] (e.g. [512, 512])
		]
	*/
	[["tripodscreen_01_large"], "4:3"],
	[["tripodscreen_01_dual"], "1:1"],
	[["flattv_01", "pcset_01_screen", "multiscreencomputer"], "16:9"],
	[["laptop", "ruggedterminal"], "16:9"]
];

{
	private _cls = _x select 0;
	private _rawRes = _x select 1;
	private _parsedRes = [_rawRes] call CFM_fnc_parseScreenResolution;
	if (_parsedRes isEqualTo []) then {
		_parsedRes = DEFAULT_SCREEN_RESOLUTION;
	};

	if (_cls isEqualType []) then {
		private _patterns = _cls apply {toLower _x};
		_patternRules pushBack [_patterns, _parsedRes];
		private _fitClasses = _allConfigClasses select {
			private _c = _x;
			(_patterns findIf {_x in _c}) != -1
		};
		{
			_resSet set [_x, +_parsedRes];
		} forEach _fitClasses;
	} else {
		private _clsLower = toLower _cls;
		_resSet set [_clsLower, +_parsedRes];
		_patternRules pushBack [[_clsLower], _parsedRes];
	};
} forEach _defaults;

parsingNamespace setVariable ["CFM_classesScreenResolutionSet", _resSet];
parsingNamespace setVariable ["CFM_screenResolutionPatterns", _patternRules];
missionNamespace setVariable ["CFM_classesScreenResolutionSet", _resSet];
missionNamespace setVariable ["CFM_screenResolutionPatterns", _patternRules];

_resSet
