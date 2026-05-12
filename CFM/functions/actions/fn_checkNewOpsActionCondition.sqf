/*
    Function: CFM_fnc_checkNewOpsActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
(_target getVariable ['CFM_menuActive', false]) && {
	(missionNamespace getVariable ["CFM_allUavsAreFeedingByDefault", false])
}
