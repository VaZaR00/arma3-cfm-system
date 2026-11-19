/*
    Function: CFM_fnc_setPPDir
    Author: Vazar & Gemini
    Description:
        Sets the camera direction vector (PP_DIR) on an operator turret
        and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _dir [Array] - 3D direction vector [x, y, z] (default []).
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_dir", []]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_DIR, _dir]] CALL_OBJCLASS("Operator", _operator);
