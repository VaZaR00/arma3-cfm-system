/*
    Function: CFM_fnc_setMonitorAllowedOperatorsTypes
    Author: Vazar & Gemini
    Description:
        Sets the allowed operator class/type filters (Monitor::_allowedOperatorsTypes, PUBLIC GLOBAL FIELD)
        for this monitor instance (classnames, type constants, or numeric operator IDs).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _allowedOperatorsTypes [String | Number | Array] - Single filter or array of class/type strings or operator IDs (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_allowedOperatorsTypes", []], ["_target", true]];
if !(_allowedOperatorsTypes isEqualTypeAny ["", 1, []]) exitWith {false};
if !(_allowedOperatorsTypes isEqualType []) then {_allowedOperatorsTypes = [_allowedOperatorsTypes]};
_allowedOperatorsTypes = _allowedOperatorsTypes select {(_x isEqualType "") || {(_x isEqualType 1)}};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_allowedOperatorsTypes", _allowedOperatorsTypes, _syncTarget);
true
