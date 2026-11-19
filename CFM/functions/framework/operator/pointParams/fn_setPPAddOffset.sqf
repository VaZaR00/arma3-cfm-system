/*
    Function: CFM_fnc_setPPAddOffset
    Author: Vazar & Gemini
    Description:
        Sets the additive camera position offset vector (PP_ADDARR) on an operator turret
        via Operator::setPPTurret and distributes via CFM remoteEvent (REMOTE_EXEC_OBJCLASS).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _addArr [Array] - 3D offset vector [x, y, z] added to memory point position (default []).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false otherwise.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_addArr", []], ["_target", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPPTurret", [_turretIndex, PP_ADDARR, _addArr], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
