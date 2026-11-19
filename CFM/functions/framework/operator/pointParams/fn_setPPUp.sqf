/*
    Function: CFM_fnc_setPPUp
    Author: Vazar & Gemini
    Description:
        Sets the camera up vector (PP_UP) on an operator turret
        and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _up [Array] - 3D up vector [x, y, z] (default []).
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_up", []]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_UP, _up]] CALL_OBJCLASS("Operator", _operator);
