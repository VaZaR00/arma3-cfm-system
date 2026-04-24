/*
    Function: CFM_fnc_connectDroneActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
IS_MONITOR_ON
(_target getVariable ['CFM_feedActive', false]) && {
	(_target getVariable ['CFM_currentOperatorIsDrone', false]) &&
	{PLAYER_ call CFM_fnc_hasUAVterminal}
}
