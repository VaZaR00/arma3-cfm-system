/*
    Function: CFM_fnc_startOperatorFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor", "_operator", ["_turret", DRIVER_TURRET_PATH], ["_reset", false]];
["startFeed", [_operator, _turret, _reset], _monitor] CALL_OBJCLASS("Monitor", _monitor);
