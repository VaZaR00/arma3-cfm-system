/*
    Function: CFM_fnc_setTurretPointParams
    Author: Vazar & Gemini
    Description:
        Sets and validates camera point alignment parameters directly on a Turret class instance
        via Turret::setPointParams and distributes execution via CFM remoteEvent (REMOTE_EXEC_OBJINSTANCE).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _params [Array] - Point alignment parameters array, or [] to apply class defaults (default []).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Array | String] - Compiled pointParams array locally, JIP ID if global, or [] if the turret instance was not found.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_params", []], ["_target", true]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {[]};
["setPointParams", [_params, false, true], _target, []] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
