/*
    Function: CFM_fnc_monitorSwitchNVGKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = GET_MON;
if !(_monitor call CFM_fnc_toggleNvgActionCondition) exitWith {};
[_monitor] call CFM_fnc_monitorToggleNVG;
