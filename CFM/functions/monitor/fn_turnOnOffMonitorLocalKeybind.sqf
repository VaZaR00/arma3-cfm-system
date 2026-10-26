/*
    Function: CFM_fnc_turnOnOffMonitorLocalKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = GET_MON;
if !(IS_OBJ(_monitor)) exitWith {};
if !(_monitor getVariable ["CFM_feedActive", false]) exitWith {};

[] call CFM_fnc_exitFullScreen;
if ([_monitor] call CFM_fnc_turnOffActionCondition) exitWith {
	[_monitor] call CFM_fnc_turnOffMonitorLocal;
};
if ([_monitor] call CFM_fnc_turnOnActionCondition) exitWith {
	[_monitor] call CFM_fnc_turnOnMonitorLocal;
};
