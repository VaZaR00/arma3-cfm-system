/*
    Function: CFM_fnc_operatorZoomActionsCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	!(_target getVariable ['CFM_currentCameraIsStatic', false])
}
