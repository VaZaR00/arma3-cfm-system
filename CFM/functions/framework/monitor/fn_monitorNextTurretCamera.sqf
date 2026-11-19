/*
    Function: CFM_fnc_monitorNextTurretCamera
    Author: Vazar & Gemini
    Description:
        Switches the connected operator camera on the monitor instance to the next available turret
        and resets active PiP/NVG effects.
        Wraps Monitor::nextTurret (PUBLIC GE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Number | Boolean] - Next turret index, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["nextTurret"] CALL_MON_INST(_monitor, _instId);
