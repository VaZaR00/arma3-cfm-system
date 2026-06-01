/*
    Function: CFM_fnc_fixFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitors", []], ["_doHint", true]];

if !(_monitors isEqualType []) then {
    _monitors = [_monitors];
    _monitors = _monitors select {IS_OBJ(_x)};
};
if (_monitors isEqualTo []) then {
    _monitors = missionNamespace getVariable ["CFM_ActiveMonitors", []];
};

private _fixed = false;
{
    if !(_x getVariable ["CFM_feedActive", false]) then {continue};
	[_x] spawn CFM_fnc_resetFeed;
    _fixed = true;
} forEach _monitors;

if !(_fixed) exitWith {};

if (_doHint) then {
CFM_STR_RESET_FIX_HINT _HINT;
};