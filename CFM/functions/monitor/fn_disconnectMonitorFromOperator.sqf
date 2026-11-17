/*
    Function: CFM_fnc_disconnectMonitorFromOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monArg", ["_caller", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["disconnect", [_caller]] CALL_MON_INST(_monitor, _instId);
