/*
    Function: CFM_fnc_monitorSwitchTIKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = GET_MON;
if !(_monitor call CFM_fnc_toggleTiActionCondition) exitWith {};
[_monitor] call CFM_fnc_monitorSwitchTi;
