/*
    Function: CFM_fnc_stopOperatorFeed
    Author: Vazar & Gemini
    Description:
        Stops rendering the active camera feed on a monitor instance, destroys its PiP camera,
        stops DisplayHandler rendering, and clears temporary feed variables.
        Wraps Monitor::stopFeed (PUBLIC LE GA GLOBAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _reset [Boolean] - True when resetting the feed without full teardown (default false).
        2: _isOptimize [Boolean] - True when pausing the feed for distance/seat optimization (default false).
        3: _target [Boolean | Number | Object | Array] - Remote execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | Any] - false on invalid monitor, otherwise method/remoteEvent result.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_reset", false], ["_isOptimize", false], ["_target", true]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["stopFeed", [_reset, _isOptimize], _target] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
