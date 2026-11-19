/*
    Function: CFM_fnc_setTurretTiParams
    Author: Vazar & Gemini
    Description:
        Sets the supported Thermal Imaging (TI) PiP mode IDs array on a Turret class instance
        (Turret::_tiParams, PUBLIC GLOBAL FIELD) via Turret::setTiParams and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _tiParams [Array] - Array of supported TI PiP effect indices (default []).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_tiParams", []], ["_target", true]];
if !(_tiParams isEqualType []) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setTiParams", [_tiParams], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
