/*
    Function: CFM_fnc_parseDisplayConfig
    Author: Vazar
    Description:
        Parses a display config class, extracts and compiles all control parameter formulas
        ("x", "y", "w", "h", "size", "sizeEx"), and stores them in a cache keyed by control idc.
        Cache is stored in missionNamespace for DEV and parsingNamespace for FINAL.
*/

#include "defines.hpp"

#ifdef FINAL
#define UI_CACHE_NAMESPACE parsingNamespace
#else
#define UI_CACHE_NAMESPACE missionNamespace
#endif

params [["_displayClass", "", [""]]];

if (_displayClass isEqualTo "") exitWith {createHashMap};

private _displayCfg = missionConfigFile >> _displayClass;
if (isNull _displayCfg) then {
	_displayCfg = configFile >> _displayClass;
};

if (isNull _displayCfg) exitWith {createHashMap};

private _controlsCache = createHashMap;

private _fnc_extractProp = {
	params ["_cfg", "_propName"];
	private _propCfg = _cfg >> _propName;
	if (isNull _propCfg) exitWith {nil};
	if (isText _propCfg) exitWith {
		[getText _propCfg] call CFM_fnc_parseControlFormula
	};
	if (isNumber _propCfg) exitWith {
		[getNumber _propCfg] call CFM_fnc_parseControlFormula
	};
	nil
};

private _fnc_parseContainer = {
	params ["_containerCfg", ["_parentIdc", -1]];
	if (isNull _containerCfg) exitWith {};

	private _ctrlClasses = configProperties [_containerCfg, "isClass _x", true];
	{
		private _ctrlCfg = _x;
		if !(isNull (_ctrlCfg >> "idc")) then {
			private _idc = getNumber (_ctrlCfg >> "idc");
			if (_idc >= 0) then {
				private _ctrlData = createHashMap;
				_ctrlData set ["parentIdc", _parentIdc];
				{
					private _formulaCode = [_ctrlCfg, _x] call _fnc_extractProp;
					if (!isNil "_formulaCode") then {
						_ctrlData set [_x, _formulaCode];
					};
				} forEach ["x", "y", "w", "h"];

				private _ctrlType = getNumber (_ctrlCfg >> "type");
				if (isText (_ctrlCfg >> "size") || {_ctrlType == 13 && {!(isNull (_ctrlCfg >> "size"))}}) then {
					private _sizeCode = [_ctrlCfg, "size"] call _fnc_extractProp;
					if (!isNil "_sizeCode") then {
						_ctrlData set ["size", _sizeCode];
					};
				};
				if (isText (_ctrlCfg >> "sizeEx")) then {
					private _sizeExCode = [_ctrlCfg, "sizeEx"] call _fnc_extractProp;
					if (!isNil "_sizeExCode") then {
						_ctrlData set ["sizeEx", _sizeExCode];
					};
				};

				_controlsCache set [_idc, _ctrlData];

				private _childControlsCfg = _ctrlCfg >> "controls";
				if (isClass _childControlsCfg) then {
					[_childControlsCfg, _idc] call _fnc_parseContainer;
				};
			};
		};
	} forEach _ctrlClasses;
};

[_displayCfg >> "controlsBackground", -1] call _fnc_parseContainer;
[_displayCfg >> "controls", -1] call _fnc_parseContainer;

if (count _controlsCache > 0) then {
	private _allDisplaysCache = UI_CACHE_NAMESPACE getVariable "CFM_displaysControlsCache";
	if (isNil "_allDisplaysCache") then {
		_allDisplaysCache = createHashMap;
	};
	_allDisplaysCache set [_displayClass, _controlsCache];
	UI_CACHE_NAMESPACE setVariable ["CFM_displaysControlsCache", _allDisplaysCache];
};

_controlsCache
