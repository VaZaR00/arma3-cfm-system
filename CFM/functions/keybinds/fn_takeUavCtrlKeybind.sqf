/*
    Function: CFM_fnc_takeUavCtrlKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monPair = GET_MON;
if !(IS_VALID_MON(_monPair)) exitWith {};
if !(_monPair call CFM_fnc_canControlMonitorSeat) exitWith {};
[_monPair] spawn CFM_fnc_takeUAVcontorls;
