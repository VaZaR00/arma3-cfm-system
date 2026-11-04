/*
    Function: CFM_fnc_exitFullScreenActionCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_target"];
if (missionNamespace getVariable ['CFM_isInPIPFullScreen', false]) exitWith {true};
if (isRemoteControlling PLAYER_) exitWith {false};
focusOn != PLAYER_
