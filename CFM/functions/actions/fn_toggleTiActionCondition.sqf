/*
    Function: CFM_fnc_toggleTiActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
HAND_MON_CONDITION
CONTROL_MON_CONDITION
IS_MONITOR_ON
(MON_GVAR(_target, _instId, 'CFM_feedActive', false)) && {
	(MON_GVAR(_target, _instId, 'CFM_canSwitchTiAction', true)) && {
	(MON_GVAR(_target, _instId, 'CFM_monitorCanSwitchTi', false)) && {
		!((equipmentDisabled (MON_GVAR(_target, _instId, 'CFM_connectedOperator', objNull)))#1) && {
			(
				!(
					(MON_GVAR(_target, _instId, 'CFM_currentTiTable', [])) isEqualTo []
				)
			)
		}
	}
	}
}
