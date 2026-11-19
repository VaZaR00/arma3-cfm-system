/*
    Function: CFM_fnc_getPPDir
    Author: Vazar & Gemini
    Description:
        Retrieves the camera direction vector (PP_DIR) from an operator turret.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _def [Array] - Default fallback direction vector (default DEF_DIR).
    Returns:
        [Array] - Direction vector [x, y, z] or _def.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_def", DEF_DIR]];
if !(IS_OBJ(_operator)) exitWith {_NIL(_def)};
[_operator, _turretIndex, PP_DIR, _NIL(_def)] call CFM_fnc_getPPTurret;
