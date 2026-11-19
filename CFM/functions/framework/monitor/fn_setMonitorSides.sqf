/*
    Function: CFM_fnc_setMonitorSides
    Author: Vazar & Gemini
    Description:
        Sets the allowed sides filter (Monitor::_monitorSides, PUBLIC GLOBAL FIELD) whose operators
        can be connected to this monitor instance. Empty array allows all sides.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _sides [Side | Array] - Side or array of Sides (west, east, independent, civilian) (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_sides", []], ["_target", true]];
if !(_sides isEqualType []) then {_sides = [_sides]};
_sides = _sides select {_x isEqualType west};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_monitorSides", _sides, _syncTarget);
true
