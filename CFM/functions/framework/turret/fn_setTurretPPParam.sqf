/*
    Function: CFM_fnc_setTurretPPParam
    Author: Vazar & Gemini
    Description:
        Updates a single pointParams field (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD)
        directly on a Turret class instance via Turret::setPPParam and distributes via CFM remoteEvent (REMOTE_EXEC_OBJINSTANCE).
    Parameters:
        0: _operator [Object | Array] - Operator object or [operatorObject, turretIndex] pair.
        1: _turret [Number | Array] - Turret index or turret path (default -1).
        2: _ppParam [String] - Point parameter constant (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD).
        3: _value [Any] - New value for the specified point parameter.
        4: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turret", -1], ["_ppParam", ""], ["_value", nil], ["_target", true]];
(RESOLVE_TURRET(_operator, _turret)) params ["_turretObject", "_turretInstanceId"];
if (!(IS_OBJ(_turretObject)) || {_turretInstanceId < 1}) exitWith {false};
["setPPParam", [_ppParam, _NIL(_value)], _target, false] REMOTE_EXEC_OBJINSTANCE("Turret", _turretInstanceId, _turretObject);
