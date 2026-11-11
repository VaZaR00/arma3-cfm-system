#include "defines.hpp"

/*
    Function: CFM_fnc_parseModuleAttributesForZen
    
    Description:
        Parses module arguments/attributes from config and converts them into the structure
        accepted by zen_dialog_fnc_create.
        Results are cached in parsingNamespace.
        If called without arguments, parses default CFM modules:
        "CFM_Module_Camera" and "CFM_Module_Monitor".

    Parameters:
        0: _moduleClass - String: class name in CfgVehicles (optional, default: "")

    Returns:
        Array - If _moduleClass given: list of controls for zen_dialog_fnc_create.
                If empty: Array of results for default modules.
*/

params [["_moduleClass", "", [""]], ["_checkUseInZen", true]];

// If called without class name, parse default CFM modules
if (_moduleClass isEqualTo "") exitWith {
    private _camRes = ["CFM_Module_Camera"] call CFM_fnc_parseModuleAttributesForZen;
    private _monRes = ["CFM_Module_Monitor"] call CFM_fnc_parseModuleAttributesForZen;
    [_camRes, _monRes]
};

// Check if already parsed and cached in parsingNamespace
private _cacheVar = format ["CFM_zenAttributes_%1", _moduleClass];
private _cached = parsingNamespace getVariable [_cacheVar, nil];
if (!isNil "_cached") exitWith {
    _cached
};

private _modConfig = configFile >> "CfgVehicles" >> _moduleClass;
if (!isClass _modConfig) exitWith { [] };

private _argsConfig = _modConfig >> "Arguments";
if (!isClass _argsConfig) then {
    _argsConfig = _modConfig >> "Attributes";
};
if (!isClass _argsConfig) exitWith { [] };

private _argClasses = "true" configClasses _argsConfig;
private _zenControls = [];
private _argNames = [];
private _argTypes = [];

{
    private _argCfg = _x;
    private _argName = configName _argCfg;
    
    // Skip base/meta classes
    if (_argName in ["Units", "ModuleDescription"]) then { continue };

    if (_checkUseInZen && {(getNumber(_argCfg >> "useInZen")) isEqualTo 0}) then { continue };

    private _displayName = getText (_argCfg >> "displayName");
    if (_displayName select [0, 1] isEqualTo "$") then {
        _displayName = localize (_displayName select [1]);
    };
    if (_displayName isEqualTo "") then { _displayName = _argName; };

    private _description = getText (_argCfg >> "description");
    if (_description select [0, 1] isEqualTo "$") then {
        _description = localize (_description select [1]);
    };

    private _typeName = toUpper (getText (_argCfg >> "typeName"));
    
    private _defaultValue = if (isNumber (_argCfg >> "defaultValue")) then {
        getNumber (_argCfg >> "defaultValue")
    } else {
        getText (_argCfg >> "defaultValue")
    };

    private _valuesCfg = _argCfg >> "values";
    if (isClass _valuesCfg) then {
        private _valClasses = "true" configClasses _valuesCfg;
        private _values = [];
        private _prettyNames = [];
        {
            private _valName = getText (_x >> "name");
            if (_valName select [0, 1] isEqualTo "$") then {
                _valName = localize (_valName select [1]);
            };
            if (_valName isEqualTo "") then { _valName = configName _x; };
            
            private _val = if (isNumber (_x >> "value")) then {
                getNumber (_x >> "value")
            } else {
                getText (_x >> "value")
            };
            _values pushBack _val;
            _prettyNames pushBack _valName;
        } forEach _valClasses;

        private _defaultIdx = _values find _defaultValue;
        if (_defaultIdx < 0) then { _defaultIdx = 0; };

        _zenControls pushBack ["COMBO", [_displayName, _description], [_values, _prettyNames, _defaultIdx]];
        _argNames pushBack _argName;
        _argTypes pushBack "COMBO";
    } else {
        if (_typeName isEqualTo "BOOL") then {
            private _defaultBool = (_defaultValue isEqualTo 1) || {_defaultValue isEqualTo "true"} || {_defaultValue isEqualTo true};
            _zenControls pushBack ["CHECKBOX", [_displayName, _description], _defaultBool];
            _argNames pushBack _argName;
            _argTypes pushBack "BOOL";
        } else {
            // "STRING" or "NUMBER" without explicit values
            private _defaultStr = if (_defaultValue isEqualType 0) then { str _defaultValue } else { _defaultValue };
            _zenControls pushBack ["EDIT", [_displayName, _description], _defaultStr];
            _argNames pushBack _argName;
            _argTypes pushBack "EDIT";
        };
    };
} forEach _argClasses;

// Save into parsingNamespace
parsingNamespace setVariable [_cacheVar, _zenControls];
parsingNamespace setVariable [format ["CFM_zenArgNames_%1", _moduleClass], _argNames];
parsingNamespace setVariable [format ["CFM_zenArgTypes_%1", _moduleClass], _argTypes];

_zenControls
