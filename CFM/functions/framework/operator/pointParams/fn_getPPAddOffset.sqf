/*
    Function: CFM_fnc_getPPAddOffset
    Author: Vazar & Gemini
    Description:
        Retrieves the additive camera position offset vector (PP_ADDARR) from an operator turret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [Array] - Default fallback vector (default [0,0,0]).
    Returns:
        [Array] - Additive offset vector [x, y, z] or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", [0,0,0]]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
[_operator, _turretIndex, PP_ADDARR, _NIL(_def)] call CFM_fnc_getPPTurret;
