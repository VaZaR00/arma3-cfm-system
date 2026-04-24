/*
    Function: CFM_fnc_toggleNvgActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	(_target getVariable ['CFM_monitorCanSwitchNvg', false]) && {
		!((equipmentDisabled (_target getVariable ['CFM_connectedOperator', objNull]))#0) && {
			(
				(_target getVariable ['CFM_currentNvgTable', createHashMap]) getOrDefault
				[((_target getVariable ['CFM_currentTurret', [-1]])#0), false]
			)
		}
	}
}
