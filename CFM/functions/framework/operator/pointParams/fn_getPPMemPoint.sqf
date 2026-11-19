/*
    Function: CFM_fnc_getPPMemPoint
    Author: Vazar & Gemini
    Description:
        Retrieves the memory point selection name (PP_MEMPOINT) from an operator turret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [String] - Default fallback memory point name (default "").
    Returns:
        [String] - Memory point name string or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", ""]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
[_operator, _turretIndex, PP_MEMPOINT, _NIL(_def)] call CFM_fnc_getPPTurret;
