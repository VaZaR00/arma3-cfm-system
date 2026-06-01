/*
    Function: CFM_fnc_getPPTurret
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_ppParam", ""], ["_def", nil]];
["getPPTurret", [_turretIndex, _ppParam, _NIL(_def)], _def] CALL_OBJCLASS("Operator", _operator);

