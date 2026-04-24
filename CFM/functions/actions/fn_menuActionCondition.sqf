/*
    Function: CFM_fnc_menuActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
HAND_MON_CONDITION
if (_target getVariable ['CFM_feedActive', false]) exitWith {false};
if (_target getVariable ['CFM_menuActive', false]) exitWith {false};
private _additionalCondition = _target getVariable ["CFM_actions_additionalCondition", {true}];
_target call _additionalCondition
