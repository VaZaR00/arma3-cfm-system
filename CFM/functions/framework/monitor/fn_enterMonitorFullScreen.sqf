/*
    Function: CFM_fnc_enterMonitorFullScreen
    Author: Vazar & Gemini
    Description:
        Switches the local player view into full-screen mode for the given monitor instance
        (either temp camera, PiP overlay, or direct vehicle optics depending on settings).
        Wraps Monitor::monitorEnterFullScreen (PUBLIC LOCAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Boolean] - true if full-screen mode was entered, false otherwise.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["monitorEnterFullScreen", []] CALL_MON_INST(_monitor, _instId);
