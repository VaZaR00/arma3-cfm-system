/*
    Function: CFM_fnc_getPPSetOffset
    Author: Vazar & Gemini
    Description:
        Retrieves the coordinate override vector (PP_SETARR) from an operator turret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [Array] - Default fallback vector (default [-1,-1,-1]).
    Returns:
        [Array] - Coordinate override vector [x, y, z] or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", [-1,-1,-1]]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
[_operator, _turretIndex, PP_SETARR, _NIL(_def)] call CFM_fnc_getPPTurret;
