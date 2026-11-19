/*
    Function: CFM_fnc_setTurretDisabled
    Author: Vazar & Gemini
    Description:
        Sets the disabled state of a Turret class instance (marks whether its camera feed is unavailable).
        Wraps Turret::setDisabled (PUBLIC LE GA - State set).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _state [Boolean] - True to mark turret disabled, false to mark enabled (default true).
        3: _target [Boolean | Number | Object | Array] - Remote execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | Any] - true on local execution, or false if the turret instance was not found.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_state", true], ["_target", true]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setDisabled", [_state], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
