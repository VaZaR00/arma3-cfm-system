/*
    Function: CFM_fnc_setTurretSignalFunc
    Author: Vazar & Gemini
    Description:
        Sets the signal strength evaluation function on a Turret class instance
        (Turret::_signalFunc, PUBLIC GLOBAL FIELD) via Turret::setSignalFunc and syncs connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _signalFunc [Code] - Signal evaluation code block returning a Number in [0..1] (default {1}).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_signalFunc", {1}], ["_target", true]];
if !(_signalFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setSignalFunc", [_signalFunc], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
