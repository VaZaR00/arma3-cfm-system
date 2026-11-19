/*
    Function: CFM_fnc_monitorToggleNVG
    Author: Vazar & Gemini
    Description:
        Toggles Night Vision (NVG) PiP effect on or off for the monitor instance.
        Wraps Monitor::switchNvg (PUBLIC GE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Boolean] - false on invalid monitor, otherwise nil/void.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["switchNvg"] CALL_MON_INST(_monitor, _instId);
