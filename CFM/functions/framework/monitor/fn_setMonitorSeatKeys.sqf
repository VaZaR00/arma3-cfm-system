/*
    Function: CFM_fnc_setMonitorSeatKeys
    Author: Vazar & Gemini
    Description:
        Sets the array of vehicle seat keys (Monitor::_seatKeys, PUBLIC GLOBAL FIELD) that can view a shared monitor instance.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatKeys [Array] - Array of seat key strings (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatKeys", []], ["_target", true]];
if !(_seatKeys isEqualType []) exitWith {false};
_seatKeys = _seatKeys select {_x isEqualType ""};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_seatKeys", _seatKeys, _syncTarget);
true
