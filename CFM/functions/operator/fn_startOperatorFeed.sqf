/*
    Function: CFM_fnc_startOperatorFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monArg", "_operator", ["_turret", DRIVER_TURRET_PATH], ["_reset", false]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["startFeed", [_operator, _turret, _reset], _monitor] CALL_MON_INST(_monitor, _instId);
