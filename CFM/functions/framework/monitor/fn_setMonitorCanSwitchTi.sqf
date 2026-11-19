/*
    Function: CFM_fnc_setMonitorCanSwitchTi
    Author: Vazar & Gemini
    Description:
        Sets whether Thermal Imaging (TI) mode switching is permitted for the current feed on a monitor instance
        (Monitor::_monitorCanSwitchTi, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canSwitchTi [Boolean] - True to allow TI toggle on the monitor, false to disallow (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canSwitchTi", false], ["_target", true]];
if !(_canSwitchTi isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_monitorCanSwitchTi", _canSwitchTi, _syncTarget);
true
