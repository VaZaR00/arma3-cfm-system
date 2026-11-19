/*
    Function: CFM_fnc_setPPSetOffset
    Author: Vazar & Gemini
    Description:
        Sets the coordinate override vector (PP_SETARR) on an operator turret
        and synchronizes it to active monitors (-1 per axis keeps original memory point coordinate).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _setArr [Array] - Coordinate override array [x, y, z] (default []).
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_setArr", []]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_SETARR, _setArr]] CALL_OBJCLASS("Operator", _operator);
