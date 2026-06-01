/*
    Function: CFM_fnc_setPPUp
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_up", []]];
["setPPTurret", [_turretIndex, PP_UP, _up]] CALL_OBJCLASS("Operator", _operator);

