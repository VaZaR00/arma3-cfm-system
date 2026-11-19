/*
    Function: CFM_fnc_getPPLod
    Author: Vazar & Gemini
    Description:
        Retrieves the model LOD name (PP_LOD) used for memory point lookup on an operator turret
        via Operator::getPPTurret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [String] - Default fallback LOD name (default "Memory").
    Returns:
        [String] - LOD name string or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", "Memory"]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
["getPPTurret", [_turretIndex, PP_LOD, _NIL(_def)], _NIL(_def)] CALL_OBJCLASS("Operator", _operator);
