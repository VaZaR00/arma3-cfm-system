/*
    Function: CFM_fnc_isTurretDisabled
    Author: Vazar & Gemini
    Description:
        Returns whether the specified Turret class instance is currently disabled.
        Wraps Turret::isDisabled (PUBLIC LOCAL - State get).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
    Returns:
        [Boolean] - true if turret instance is disabled, false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["isDisabled", [], false] CALL_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
