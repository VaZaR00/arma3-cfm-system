#include "defines.hpp"

if (!hasInterface) exitWith {};

if (!isNil "zen_custom_modules_fnc_register") then {
    call CFM_fnc_registerZenModules;
} else {
    ["CBA_loadingScreenDone", {
        if (!isNil "zen_custom_modules_fnc_register") then {
            call CFM_fnc_registerZenModules;
        };
    }] call CBA_fnc_addEventHandler;
};

["CFM_initModuleMonitor", {_this call CFM_fnc_initModuleMonitor}] call CBA_fnc_addEventHandler;
["CFM_initModuleOperator", {_this call CFM_fnc_initModuleOperator}] call CBA_fnc_addEventHandler;