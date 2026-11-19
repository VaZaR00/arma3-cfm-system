/*
    Function: CFM_fnc_setPointAlignment
    Author: Vazar & Gemini
    Description:
        Sets the camera point alignment parameters for an operator turret via Operator::setPointParams
        and synchronizes active monitors on target machines via CFM remoteEvent (REMOTE_EXEC_OBJCLASS).
    Parameters:
        0: _operator [Object] - Target operator object (default objNull).
        1: _turretIndex [Number | Array] - Turret index or path (default -1).
        2: _params [Array | Number] - Point alignment params array or -1 to reset to class default (default []).
        3: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Array | Boolean | String] - Updated compiled pointParams array locally, JIP ID if global, or false on invalid operator.
*/

#include "defines.hpp"

params [["_operator", objNull], ["_turretIndex", -1], ["_params", []], ["_target", true]];
if !(IS_OBJ(_operator)) exitWith {false};
["setPointParams", [_turretIndex, _params, false], _target, false] REMOTE_EXEC_OBJCLASS("Operator", _operator);
