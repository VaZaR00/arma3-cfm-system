/*
    Function: CFM_fnc_setTurretSignalFunc
    Author: Vazar & Gemini
    Description:
        Sets the signal strength evaluation function on a Turret class instance
        (Turret::_signalFunc, PUBLIC GLOBAL FIELD). Should return a Number in [0..1].
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _signalFunc [Code] - Signal evaluation code block (default {1}).
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_signalFunc", {1}], ["_target", true]];
if !(_signalFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "signalFunc", _signalFunc, _syncTarget);
true
