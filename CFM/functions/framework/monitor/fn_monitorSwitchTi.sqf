/*
    Function: CFM_fnc_monitorSwitchTi
    Author: Vazar & Gemini
    Description:
        Cycles through available Thermal Imaging (TI) PiP modes for the current operator camera
        on the monitor instance (or returns to normal vision after the last TI mode).
        Wraps Monitor::switchTi (PUBLIC GE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Boolean] - false on invalid monitor, otherwise nil/void.
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["switchTi"] CALL_MON_INST(_monitor, _instId);
