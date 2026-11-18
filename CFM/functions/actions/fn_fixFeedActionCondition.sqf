/*
    Function: CFM_fnc_fixFeedActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
HAND_MON_CONDITION
IS_MONITOR_ON
if !(MON_GVAR(_target, _instId, 'CFM_canFixAction', true)) exitWith {false};
(MON_GVAR(_target, _instId, 'CFM_feedActive', false))
