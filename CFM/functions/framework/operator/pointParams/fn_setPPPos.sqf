/*
    Function: CFM_fnc_setPPPos
    Author: Vazar & Gemini
    Description:
        Sets the static camera position or model offset (PP_POS) on an operator turret
        and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _pos [Array] - 3D position or offset vector [x, y, z] (default []).
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_pos", []]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_POS, _pos]] CALL_OBJCLASS("Operator", _operator);
