/*
    Function: CFM_fnc_setTurretNvgParam
    Author: Vazar & Gemini
    Description:
        Sets whether Night Vision (NVG) mode is supported on a Turret class instance
        (Turret::_nvgParam, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _nvgParam [Boolean] - True if NVG is supported, false otherwise (default false).
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_nvgParam", false], ["_target", true]];
if !(_nvgParam isEqualType false) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "nvgParam", _nvgParam, _syncTarget);
true
