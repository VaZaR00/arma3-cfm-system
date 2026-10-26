/*
    Function: CFM_fnc_setPasswordActionCondition
    Author: Vazar
    Description: Condition for "Set Password" monitor action.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
if !(_target getVariable ["CFM_canSetPassword", false]) exitWith {false};
if !((_target getVariable ["CFM_password", ""]) isEqualTo "") exitWith {false};
(_target getVariable ["CFM_menuActive", false]) || (_target getVariable ["CFM_feedActive", false])
