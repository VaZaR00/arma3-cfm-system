#include "defines.hpp"

/*
    Function: CFM_fnc_openZenModuleDialog
    
    Description:
        Opens the ZEN dialog for a CFM module and creates/initializes it upon confirmation.
        
    Parameters:
        0: _moduleClass - String
        1: _pos - Array [x, y, z]
        2: _target - Object
*/

params [
    ["_moduleClass", "", [""]],
    ["_pos", [0,0,0], [[]]],
    ["_target", objNull, [objNull]]
];

if (_moduleClass isEqualTo "") exitWith {};
if (isNil "zen_dialog_fnc_create") exitWith {};

// Get parsed controls from parsingNamespace (or parse on demand)
private _content = parsingNamespace getVariable [format ["CFM_zenAttributes_%1", _moduleClass], []];
if (_content isEqualTo []) then {
    _content = [_moduleClass] call CFM_fnc_parseModuleAttributesForZen;
};
if (_content isEqualTo []) exitWith {};

// Make a copy so we can customize defaults per-placement without modifying the cached array
_content = +_content;

private _argNames = parsingNamespace getVariable [format ["CFM_zenArgNames_%1", _moduleClass], []];
private _argTypes = parsingNamespace getVariable [format ["CFM_zenArgTypes_%1", _moduleClass], []];

// If _target is an object, pre-populate target object field in the dialog
private _targetVarName = if (_moduleClass isEqualTo "CFM_Module_Camera") then {"cameraObject"} else {"monitorObject"};
private _targetIdx = _argNames find _targetVarName;

if (_targetIdx != -1 && {!isNull _target}) then {
    private _targetName = vehicleVarName _target;
    if (_targetName isEqualTo "") then {
        _targetName = format ["CFM_zenTarget_%1_%2", typeOf _target, round (time * 1000)];
        _target setVehicleVarName _targetName;
        missionNamespace setVariable [_targetName, _target, true];
    };
    private _ctrl = _content select _targetIdx;
    _ctrl set [2, _targetName];
};

// Window title from displayName
private _title = getText (configFile >> "CfgVehicles" >> _moduleClass >> "displayName");
if (_title select [0, 1] isEqualTo "$") then {
    _title = localize (_title select [1]);
};
if (_title isEqualTo "") then { _title = _moduleClass; };

[
    _title,
    _content,
    {
        params ["_dialogValues", "_args"];
        _args params ["_moduleClass", "_pos", "_target", "_argNames", "_argTypes"];

        // 1. Create the module logic object
        private _group = createGroup sideLogic;
        private _logic = _group createUnit [_moduleClass, _pos, [], 0, "CAN_COLLIDE"];
        _logic setPosASL (AGLToASL _pos);

        if (!isNull _target) then {
            _logic attachTo [_target];
            _logic setVariable ["bis_fnc_curatorAttachObject_object", _target, true];
        } else {
            if (!isNull curatorCamera) then {
                _logic setVectorDirAndUp [vectorDir curatorCamera, vectorUp curatorCamera];
            };
        };

        // 2. Set variables from dialog values
        {
            private _varName = _argNames select _forEachIndex;
            private _val = _x;
            _logic setVariable [_varName, _val, true];
        } forEach _dialogValues;

        _logic setVariable ["CFM_zenInitialized", true, true];

        // 3. Initialize module
        if (_moduleClass isEqualTo "CFM_Module_Camera") then {
            if (isServer) then {
                [_logic, [], true] call CFM_fnc_initModuleOperator;
            } else {
                ["CFM_initModuleOperator", [_logic, [], true]] call CBA_fnc_serverEvent;
            };
        } else {
            // Monitor is global
            ["CFM_initModuleMonitor", [_logic, [], true]] call CBA_fnc_globalEventJIP;
        };
    },
    {},
    [_moduleClass, _pos, _target, _argNames, _argTypes]
] call zen_dialog_fnc_create;
