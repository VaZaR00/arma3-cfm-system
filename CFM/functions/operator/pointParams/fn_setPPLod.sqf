/*
    Function: CFM_fnc_setPPLod
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_lod", "Memory"]];
["setPPTurret", [_turretIndex, PP_LOD, _lod]] CALL_OBJCLASS("Operator", _operator);

