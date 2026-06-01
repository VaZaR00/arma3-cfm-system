/*
    Function: CFM_fnc_setPPPos
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_pos", []]];
["setPPTurret", [_turretIndex, PP_POS, _pos]] CALL_OBJCLASS("Operator", _operator);

