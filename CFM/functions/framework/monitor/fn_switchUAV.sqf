/*
    Function: CFM_fnc_switchUAV
    Author: Vazar & Gemini
    Description:
        Swaps the UAV currently controlled via terminal by the local player with the UAV
        connected to the given monitor instance.
        Wraps Monitor::switchUAV (PUBLIC LOCAL - State set, spawned due to waitUntil).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Script | Boolean] - Script handle when spawned, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["switchUAV"] SPAWN_MON_INST(_monitor, _instId);
