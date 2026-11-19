/*
    Function: CFM_fnc_setTurretInitInterfaceFunc
    Author: Vazar & Gemini
    Description:
        Sets the UI interface initialization function executed when the display is created
        on a Turret class instance (Turret::_initInterfaceFunc, PUBLIC GLOBAL FIELD) via Turret::setInitInterfaceFunc
        and restarts DisplayHandler rendering on active connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _initInterfaceFunc [Code] - Interface initialization code block (default {}).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_initInterfaceFunc", {}], ["_target", true]];
if !(_initInterfaceFunc isEqualType {}) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setInitInterfaceFunc", [_initInterfaceFunc], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
