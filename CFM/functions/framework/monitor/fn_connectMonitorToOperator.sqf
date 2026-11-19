/*
    Function: CFM_fnc_connectMonitorToOperator
    Author: Vazar & Gemini
    Description:
        Connects a monitor instance to a camera operator (unit, vehicle, UAV, or static camera)
        and synchronizes the feed across clients according to the monitor locality mode.
        Wraps Monitor::connect (PUBLIC GE GA LOCAL - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _operator [Object] - Target operator object to receive the camera feed from.
        2: _caller [Object] - Optional unit that initiated the connection (default objNull).
    Returns:
        [Boolean] - true if connection sequence started, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_operator", objNull], ["_caller", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["connect", [_operator, _caller], false] CALL_MON_INST(_monitor, _instId);
