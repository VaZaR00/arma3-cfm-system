/*
    Function: CFM_fnc_disconnectMonitorFromOperatorKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monPair = GET_MON;
if !(IS_VALID_MON(_monPair)) exitWith {};
if !(_monPair call CFM_fnc_canControlMonitorSeat) exitWith {};
[] call CFM_fnc_exitFullScreen;
[_monPair, PLAYER_] call CFM_fnc_disconnectMonitorFromOperator;
