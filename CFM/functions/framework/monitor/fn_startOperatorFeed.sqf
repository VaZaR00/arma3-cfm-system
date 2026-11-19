/*
    Function: CFM_fnc_startOperatorFeed
    Author: Vazar & Gemini
    Description:
        Starts rendering the camera feed from an operator turret onto a monitor instance.
        Wraps Monitor::startFeed (PUBLIC LE GA GLOBAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _operator [Object] - Operator object providing the camera feed.
        2: _turret [Array | Number] - Target turret path or index (default DRIVER_TURRET_PATH).
        3: _reset [Boolean] - True if restarting/resetting an active feed (default false).
        4: _target [Boolean | Number | Object | Array] - Remote execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | Array | String] - Start result when executed locally, JIP ID if global, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_operator", objNull], ["_turret", DRIVER_TURRET_PATH], ["_reset", false], ["_target", true]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["startFeed", [_operator, _turret, _reset], _target, _monitor] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
