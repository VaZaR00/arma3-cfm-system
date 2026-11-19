/*
    Function: CFM_fnc_setTurretInterfaceFunc
    Author: Vazar & Gemini
    Description:
        Sets the per-frame UI interface update function on a Turret class instance
        (Turret::_interfaceFunc, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _interfaceFunc [Code] - Interface update code block (default {}).
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_interfaceFunc", {}], ["_target", true]];
if !(_interfaceFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "interfaceFunc", _interfaceFunc, _syncTarget);
true
