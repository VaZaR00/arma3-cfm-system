/*
    Function: CFM_fnc_setPPMemPoint
    Author: Vazar & Gemini
    Description:
        Sets the memory point selection name (PP_MEMPOINT) used for turret camera attachment
        on an operator and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _memPoint [String] - Memory point selection name (default "").
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_memPoint", ""]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_MEMPOINT, _memPoint]] CALL_OBJCLASS("Operator", _operator);
