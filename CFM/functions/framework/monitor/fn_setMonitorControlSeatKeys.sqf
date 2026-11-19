/*
    Function: CFM_fnc_setMonitorControlSeatKeys
    Author: Vazar & Gemini
    Description:
        Sets the array of seat keys (Monitor::_controlSeatKeys, PUBLIC GLOBAL FIELD) permitted to control a shared vehicle monitor instance.
        An empty array allows all seats in _seatKeys to control the monitor.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _controlSeatKeys [Array] - Array of controlling seat key strings (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_controlSeatKeys", []], ["_target", true]];
if !(_controlSeatKeys isEqualType []) exitWith {false};
_controlSeatKeys = _controlSeatKeys select {_x isEqualType ""};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_controlSeatKeys", _controlSeatKeys, _syncTarget);
true
