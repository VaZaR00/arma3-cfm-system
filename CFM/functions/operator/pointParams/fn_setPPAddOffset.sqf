/*
    Function: CFM_fnc_setPPAddOffset
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_addArr", []]];
["setPPTurret", [_turretIndex, PP_ADDARR, _addArr]] CALL_OBJCLASS("Operator", _operator);

