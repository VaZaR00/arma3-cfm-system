/*
    Function: CFM_fnc_menuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
IN_VEH_TABLET_CONDITION
CONTROL_MON_CONDITION
if ([_target, _instId] call CFM_fnc_handMonitorMenuActionCondition) exitWith {false};
if ([_target, _instId] call CFM_fnc_hasMonitorPasswordAccess) then {
	if (MON_GVAR(_target, _instId, 'CFM_feedActive', false)) exitWith {false};
	if (MON_GVAR(_target, _instId, 'CFM_menuActive', false)) exitWith {false};
	private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
	_target call _additionalCondition
} else {
	private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
	_target call _additionalCondition
};
