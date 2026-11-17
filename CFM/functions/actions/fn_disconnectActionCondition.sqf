/*
    Function: CFM_fnc_disconnectActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
HAND_MON_CONDITION
MON_GVAR(_target, _instId, 'CFM_feedActive', false)
