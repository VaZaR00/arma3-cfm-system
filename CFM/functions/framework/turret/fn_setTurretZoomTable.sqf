/*
    Function: CFM_fnc_setTurretZoomTable
    Author: Vazar & Gemini
    Description:
        Sets the zoom-to-FOV HashMap lookup table on a Turret class instance
        (Turret::_zoomTable, PUBLIC GLOBAL FIELD) via Turret::setZoomTable and updates connected monitors.
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _zoomTable [HashMap] - HashMap mapping zoom levels to camera FOV values (default createHashMap).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_zoomTable", createHashMap], ["_target", true]];
if !(_zoomTable isEqualType createHashMap) exitWith {false};
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setZoomTable", [_zoomTable], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
