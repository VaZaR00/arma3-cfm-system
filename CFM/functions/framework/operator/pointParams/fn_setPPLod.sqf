/*
    Function: CFM_fnc_setPPLod
    Author: Vazar & Gemini
    Description:
        Sets the LOD name (PP_LOD) used for memory point lookup on an operator turret
        and synchronizes it to active monitors.
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _lod [String] - Model LOD name (e.g. "Memory", "ViewGunner") (default "Memory").
    Returns:
        [Boolean] - true if updated successfully, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_lod", "Memory"]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_LOD, _lod]] CALL_OBJCLASS("Operator", _operator);
