/*
    Function: CFM_fnc_setPPAddOffset
    Author: Vazar & Gemini
    Description:
        Sets the additive camera position offset vector (PP_ADDARR) on an operator turret
        and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _addArr [Array] - 3D offset vector [x, y, z] added to memory point position (default []).
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_addArr", []]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_ADDARR, _addArr]] CALL_OBJCLASS("Operator", _operator);
