/*
    Function: CFM_fnc_setTurretEffectFunc
    Author: Vazar & Gemini
    Description:
        Sets the UI visual effects handler code on a Turret class instance
        (Turret::_effectFunc, PUBLIC GLOBAL FIELD) via Turret::setEffectFunc and syncs connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _effectFunc [Code] - Effects update code block (default {}).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_effectFunc", {}], ["_target", true]];
if !(_effectFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setEffectFunc", [_effectFunc], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
