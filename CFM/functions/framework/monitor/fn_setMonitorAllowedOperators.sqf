/*
    Function: CFM_fnc_setMonitorAllowedOperators
    Author: Vazar & Gemini
    Description:
        Sets the whitelist of specific operator objects (Monitor::_allowedOperators, PUBLIC GLOBAL FIELD)
        that can be viewed on this monitor instance. Empty array allows any operator matching sides/types.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _allowedOperators [Object | Array] - Operator object or array of operator objects (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_allowedOperators", []], ["_target", true]];
if !(_allowedOperators isEqualTypeAny [objNull, []]) exitWith {false};
if !(_allowedOperators isEqualType []) then {_allowedOperators = [_allowedOperators]};
_allowedOperators = _allowedOperators select {_x isEqualType objNull};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_allowedOperators", _allowedOperators, _syncTarget);
true
