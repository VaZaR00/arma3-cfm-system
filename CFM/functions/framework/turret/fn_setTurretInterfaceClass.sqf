/*
    Function: CFM_fnc_setTurretInterfaceClass
    Author: Vazar & Gemini
    Description:
        Sets the UI display/dialog config class name used to render the feed interface
        on a Turret class instance (Turret::_interfaceClass, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _interfaceClass [String] - UI display class name (empty string for raw R2T) (default "").
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_interfaceClass", ""], ["_target", true]];
if !(_interfaceClass isEqualType "") exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "interfaceClass", _interfaceClass, _syncTarget);
true
