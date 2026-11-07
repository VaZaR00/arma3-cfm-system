/*
    Function: CFM_fnc_getDefaultScreenResolution
    Author: Vazar
    Description:
        Returns default [width, height] screen resolution preset for a monitor object or classname.
*/

#include "defines.hpp"

params [["_objClass", ""]];

if (isNil "CFM_initDefScreenResolutionsSet") then {
	0 call CFM_fnc_setupDefScreenResolutions;
};

if (_objClass isEqualType objNull) then {
	_objClass = if (IS_OBJ(_objClass)) then {typeOf _objClass} else {""};
};

if (!(_objClass isEqualType "") || {_objClass isEqualTo ""}) exitWith {
	+DEFAULT_SCREEN_RESOLUTION
};

_objClass = toLower _objClass;

private _resSet = missionNamespace getVariable ["CFM_classesScreenResolutionSet", createHashMap];
private _predefinedRes = _resSet get _objClass;

if (!isNil "_predefinedRes" && {_predefinedRes isEqualType []} && {count _predefinedRes >= 2}) exitWith {
	+_predefinedRes
};

private _patternRules = missionNamespace getVariable ["CFM_screenResolutionPatterns", []];
private _foundRes = [];
{
	_x params [["_patterns", []], ["_res", DEFAULT_SCREEN_RESOLUTION]];
	if ((_patterns findIf {(_x in _objClass) || {_objClass isKindOf _x}}) != -1) exitWith {
		_foundRes = +_res;
	};
} forEach _patternRules;

if (_foundRes isEqualTo []) then {
	_foundRes = +DEFAULT_SCREEN_RESOLUTION;
};

_resSet set [_objClass, _foundRes];
+_foundRes
