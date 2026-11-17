/*
    Function: CFM_fnc_turnOnOffMonitorLocalKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monPair = GET_MON;
if !(IS_VALID_MON(_monPair)) exitWith {};
_monPair params ["_monitor", "_instId"];
if !(MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) exitWith {};

[] call CFM_fnc_exitFullScreen;
if (_monPair call CFM_fnc_turnOffActionCondition) exitWith {
	[_monPair] call CFM_fnc_turnOffMonitorLocal;
};
if (_monPair call CFM_fnc_turnOnActionCondition) exitWith {
	[_monPair] call CFM_fnc_turnOnMonitorLocal;
};
