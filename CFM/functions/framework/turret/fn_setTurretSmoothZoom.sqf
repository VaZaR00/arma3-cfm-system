/*
    Function: CFM_fnc_setTurretSmoothZoom
    Author: Vazar & Gemini
    Description:
        Sets whether zoom FOV transitions are smoothed on a Turret class instance
        (Turret::_smoothZoom, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _smoothZoom [Boolean] - True for smooth FOV interpolation, false for instant zoom (default true).
        3: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_smoothZoom", true], ["_target", true]];
if !(_smoothZoom isEqualType false) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
TURR_SVARG(_turretObject, _turretInstanceId, "smoothZoom", _smoothZoom, _syncTarget);
true
