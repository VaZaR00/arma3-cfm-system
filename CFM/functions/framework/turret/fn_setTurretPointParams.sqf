/*
    Function: CFM_fnc_setTurretPointParams
    Author: Vazar & Gemini
    Description:
        Sets and validates camera point alignment parameters directly on a Turret class instance
        and broadcasts compiled point parameters globally.
        Wraps Turret::setPointParams (PUBLIC LE GE GA - Config set).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _params [Array] - Point alignment parameters array, or [] to apply class defaults (default []).
    Returns:
        [Array] - Compiled pointParams array, or [] if the turret instance was not found.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_params", []]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {[]};
["setPointParams", [_params, true], []] CALL_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
