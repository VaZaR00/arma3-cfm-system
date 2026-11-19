/*
    Function: CFM_fnc_setTurretCanMoveCamera
    Author: Vazar & Gemini
    Description:
        Sets whether remote camera rotation/movement from monitors is allowed on a Turret class instance
        (Turret::_canMoveCamera, PUBLIC GLOBAL FIELD) via Turret::setCanMoveCamera and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _canMoveCamera [Boolean] - True to allow remote camera movement, false to lock (default false).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_canMoveCamera", false], ["_target", true]];
if !(_canMoveCamera isEqualType false) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setCanMoveCamera", [_canMoveCamera], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
