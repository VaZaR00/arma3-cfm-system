/*
    Function: CFM_fnc_getOperatorInfo
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg"];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {};
["getOperatorInfo", [], []] CALL_MON_INST(_monitor, _instId);
