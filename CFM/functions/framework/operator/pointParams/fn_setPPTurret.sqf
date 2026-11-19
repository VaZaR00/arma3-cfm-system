/*
    Function: CFM_fnc_setPPTurret
    Author: Vazar & Gemini
    Description:
        Updates a single pointParams field (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD)
        on the specified operator turret via Operator::setPPTurret and distributes via CFM remoteEvent (REMOTE_EXEC_OBJCLASS).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _ppParam [String] - Point parameter constant (PP_POS, PP_DIR, PP_UP, PP_MEMPOINT, PP_ADDARR, PP_SETARR, PP_LOD).
        3: _value [Any] - New value for the specified point parameter.
        4: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_ppParam", ""], ["_value", nil], ["_target", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, _ppParam, _NIL(_value)], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
