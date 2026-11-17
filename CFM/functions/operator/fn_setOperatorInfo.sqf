/*
    Function: CFM_fnc_setOperatorInfo
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_set", false], ["_operator", nil]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["setOperatorInfo", [_set, _NIL(_operator)]] CALL_MON_INST(_monitor, _instId);
