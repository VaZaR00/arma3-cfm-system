#include "defines.hpp"

/*
    Function: CFM_fnc_registerZenModules
    
    Description:
        Registers CFM Camera and Monitor modules in the ZEN (Zeus Enhanced) framework.
*/

if (!hasInterface) exitWith {};
if (isNil "zen_custom_modules_fnc_register") exitWith {};

private _category = localize "STR_CFM_Module_categoryName";
if (_category select [0, 1] isEqualTo "$") then {
    _category = localize (_category select [1]);
};
if (_category isEqualTo "") then { _category = "CFM Camera System"; };

// 1. Camera Module
[
    _category,
    localize "STR_CFM_Module_moduleCameraName",
    {
        params ["_pos", "_target"];
        ["CFM_Module_Camera", _pos, _target] call CFM_fnc_openZenModuleDialog;
    },
    "IconCamera"
] call zen_custom_modules_fnc_register;

// 2. Monitor Module
[
    _category,
    localize "STR_CFM_Module_moduleMonitorName",
    {
        params ["_pos", "_target"];
        ["CFM_Module_Monitor", _pos, _target] call CFM_fnc_openZenModuleDialog;
    },
    "\A3\modules_f\data\portraitStrategicMapImage_ca.paa"
] call zen_custom_modules_fnc_register;
