/*
    Function: CFM_fnc_toggleTiActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	(_target getVariable ['CFM_monitorCanSwitchTi', false]) && {
		!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#1) && {
			(
				!(
					(
						(_target getVariable ['CFM_currentTiTable', createHashMap]) getOrDefault
						[((_target getVariable ['CFM_currentTurret', [-1]])#0), []]
					) isEqualTo []
				)
			)
		}
	}
}
