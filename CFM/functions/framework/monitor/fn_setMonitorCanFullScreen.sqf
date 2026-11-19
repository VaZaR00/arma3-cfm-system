/*
    Function: CFM_fnc_setMonitorCanFullScreen
    Author: Vazar & Gemini
    Description:
        Enables or disables full-screen mode capability (Monitor::_canFullScreen, PUBLIC GLOBAL FIELD) on a monitor instance.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canFullScreen [Boolean] - True to allow full-screen mode, false to forbid (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canFullScreen", false], ["_target", true]];
if !(_canFullScreen isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_canFullScreen", _canFullScreen, _syncTarget);
true
