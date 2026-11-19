/*
    Function: CFM_fnc_setTurretDefaultPointAlignment
    Author: Vazar & Gemini
    Description:
        Resets point alignment parameters on a specific Turret class instance back to its default class preset.
        Wraps Turret::setDefaultPointAlignment (PUBLIC GE GA LOCAL - Config set).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
    Returns:
        [Array | Boolean] - Updated pointParams or false if the turret instance was not found.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setDefaultPointAlignment", []] CALL_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
