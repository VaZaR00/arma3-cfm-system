/*
    Function: CFM_fnc_setPPTurret
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_ppParam", ""], ["_value", nil]];
["setPPTurret", [_turretIndex, _ppParam, _value]] CALL_OBJCLASS("Operator", _operator);

