/*
    Function: CFM_fnc_changePasswordActionCondition
    Author: Vazar
    Description: Condition for "Change Password" monitor action.
*/

#include "defines.hpp" 

params["_target", ["_instId", -1]];
RESOLVE_ACTION_INST
HAND_MON_CONDITION
if !(MON_GVAR(_target, _instId, "CFM_canSetPassword", false)) exitWith {false};
if ((MON_GVAR(_target, _instId, "CFM_password", "")) isEqualTo "") exitWith {false};
(MON_GVAR(_target, _instId, "CFM_menuActive", false)) || (MON_GVAR(_target, _instId, "CFM_feedActive", false))
