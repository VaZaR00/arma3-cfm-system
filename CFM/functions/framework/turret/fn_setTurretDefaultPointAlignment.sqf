/*
    Function: CFM_fnc_setTurretDefaultPointAlignment
    Author: Vazar & Gemini
    Description:
        Resets point alignment parameters on a specific Turret class instance back to its default class preset
        via Turret::setDefaultPointAlignment and distributes via CFM remoteEvent (REMOTE_EXEC_OBJINSTANCE).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Array | Boolean | String] - Updated pointParams locally, JIP ID if global, or false if the turret instance was not found.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_target", true]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setDefaultPointAlignment", [], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
