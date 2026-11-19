/*
    Function: CFM_fnc_getPPPos
    Author: Vazar & Gemini
    Description:
        Retrieves the static camera position or model offset vector (PP_POS) from an operator turret
        via Operator::getPPTurret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [Array] - Default fallback position vector (default []).
    Returns:
        [Array] - Position vector [x, y, z] or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", []]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
["getPPTurret", [_turretIndex, PP_POS, _NIL(_def)], _NIL(_def)] CALL_OBJCLASS("Operator", _operator);
