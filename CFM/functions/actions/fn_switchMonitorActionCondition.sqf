/*
    Function: CFM_fnc_switchMonitorActionCondition
    Author: Vazar
    Description: Action condition for switching active monitor instance on multi-monitor objects.
*/

#include "defines.hpp"

params ["_target"];

if !(IS_OBJ(_target)) exitWith {false};
if !(_target getVariable ["CFM_isMonitorSet", false]) exitWith {false};
if (_target getVariable ["CFM_isHandTablet", false]) exitWith {false};

private _available = [_target] call CFM_fnc_getAvailableMonitorInstances;
if ((count _available) <= 1) exitWith {false};

private _selectedInstId = [_target] call CFM_fnc_getSelectedMonitorInstance;
if (_selectedInstId < 1) exitWith {false};

if ((objectParent PLAYER_) isEqualTo _target && {call CFM_fnc_hasDualTabletMenu}) exitWith {
	[_target, _selectedInstId] call CFM_fnc_isSelectedTablet
};

true
