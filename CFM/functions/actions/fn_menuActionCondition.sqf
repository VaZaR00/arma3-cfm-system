/*
    Function: CFM_fnc_menuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
IN_VEH_TABLET_CONDITION
if ([_target] call CFM_fnc_handMonitorMenuActionCondition) exitWith {false};
if ([_target] call CFM_fnc_hasMonitorPasswordAccess) then {
	if (_target getVariable ['CFM_feedActive', false]) exitWith {false};
	if (_target getVariable ['CFM_menuActive', false]) exitWith {false};
	private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
	_target call _additionalCondition
} else {
	private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
	_target call _additionalCondition
};
