/*
    Function: CFM_fnc_setTurretNvgParam
    Author: Vazar & Gemini
    Description:
        Sets whether Night Vision (NVG) mode is supported on a Turret class instance
        (Turret::_nvgParam, PUBLIC GLOBAL FIELD) via Turret::setNvgParam and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _nvgParam [Boolean] - True if NVG is supported, false otherwise (default false).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_nvgParam", false], ["_target", true]];
if !(_nvgParam isEqualType false) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setNvgParam", [_nvgParam], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
