/*
    Function: CFM_fnc_setTurretEffectFunc
    Author: Vazar & Gemini
    Description:
        Sets the UI visual effects handler code on a Turret class instance
        (Turret::_effectFunc, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _effectFunc [Code] - Effects update code block (default {}).
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_effectFunc", {}], ["_target", true]];
if !(_effectFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "effectFunc", _effectFunc, _syncTarget);
true
