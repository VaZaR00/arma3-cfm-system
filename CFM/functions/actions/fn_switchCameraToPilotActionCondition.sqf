/*
    Function: CFM_fnc_switchCameraToPilotActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	(_target getVariable ['CFM_currentOpHasTurrets', false]) && {
		((_target getVariable ['CFM_currentTurret', [-1]]) isEqualTo [0])
	}
}
