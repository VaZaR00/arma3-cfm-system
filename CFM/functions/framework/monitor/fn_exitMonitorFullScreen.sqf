/*
    Function: CFM_fnc_exitMonitorFullScreen
    Author: Vazar & Gemini
    Description:
        Exits full-screen mode for the given monitor instance and restores the camera feed
        back to the monitor render target or PiP window.
        Wraps Monitor::monitorExitFullScreen (PUBLIC LOCAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Boolean] - true if full-screen mode was exited, false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["monitorExitFullScreen", []] CALL_MON_INST(_monitor, _instId);
