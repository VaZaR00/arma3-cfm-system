/*
    Function: CFM_fnc_setTurretCameraMoveRestrictions
    Author: Vazar & Gemini
    Description:
        Sets angular movement restrictions [upDeg, downDeg, leftDeg, rightDeg] on a Turret class instance
        (Turret::_cameraMoveRestrictions, PUBLIC GLOBAL FIELD) via Turret::setCameraMoveRestrictions and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _restrictions [Array] - Array [up, down, left, right] in degrees (default DEF_CAM_MOVE_RESTR).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_restrictions", DEF_CAM_MOVE_RESTR], ["_target", true]];
if !(_restrictions isEqualType []) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setCameraMoveRestrictions", [_restrictions], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
