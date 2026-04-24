/*
    Function: CFM_fnc_watchTabletActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
(_target getVariable ['CFM_feedActive', false]) &&
{(_target getVariable ["CFM_isHandMonitor", false]) &&
{(_target getVariable ["CFM_turnedOffLocal", false])}}
