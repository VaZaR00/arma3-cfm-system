/*
    Function: CFM_fnc_nextTurretKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _monitor = GET_MON;
if !(_monitor call CFM_fnc_switchCameraTurretActionCondition) exitWith {};
[_monitor] call CFM_fnc_monitorNextTurretCamera;
