/*
    Function: CFM_fnc_disconnectMonitorFromOperator
    Author: Vazar & Gemini
    Description:
        Disconnects a monitor instance from its currently active camera operator,
        stops the video feed, and clears temporary feed state variables.
        Wraps Monitor::disconnect (PUBLIC GE GA LOCAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _caller [Object] - Optional unit that initiated the disconnection (default objNull).
    Returns:
        [Boolean] - false on invalid monitor, otherwise nil/void.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_caller", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["disconnect", [_caller]] CALL_MON_INST(_monitor, _instId);
