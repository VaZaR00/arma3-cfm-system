/*
    Function: CFM_fnc_setTurretSmoothZoom
    Author: Vazar & Gemini
    Description:
        Sets whether zoom FOV transitions are smoothed on a Turret class instance
        (Turret::_smoothZoom, PUBLIC GLOBAL FIELD) via Turret::setSmoothZoom and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _smoothZoom [Boolean] - True for smooth FOV interpolation, false for instant zoom (default true).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_smoothZoom", true], ["_target", true]];
if !(_smoothZoom isEqualType false) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setSmoothZoom", [_smoothZoom], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
