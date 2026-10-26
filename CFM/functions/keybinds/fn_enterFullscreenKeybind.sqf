/*
    Function: CFM_fnc_enterFullscreenKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = GET_MON;
if !(IS_OBJ(_monitor)) exitWith {};
if !([_monitor] call CFM_fnc_enterFullScreenActionCondition) exitWith {};
[_monitor] call CFM_fnc_enterMonitorFullScreen;
