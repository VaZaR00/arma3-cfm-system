/*
    Function: CFM_fnc_setPPSetArr
*/

#include "defines.hpp"

params[["_operator", objNull], ["_turretIndex", -1], ["_setArr", []]];
["setPPTurret", [_turretIndex, PP_SETARR, _setArr]] CALL_OBJCLASS("Operator", _operator);

