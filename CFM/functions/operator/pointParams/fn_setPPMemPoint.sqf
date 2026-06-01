/*
    Function: CFM_fnc_setPPMemPoint
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_memPoint", ""]];
["setPPTurret", [_turretIndex, PP_MEMPOINT, _memPoint]] CALL_OBJCLASS("Operator", _operator);

