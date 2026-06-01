/*
    Function: CFM_fnc_setPPDir
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_dir", []]];
["setPPTurret", [_turretIndex, PP_DIR, _dir]] CALL_OBJCLASS("Operator", _operator);

