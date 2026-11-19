/*
    Function: CFM_fnc_setMonitorAllowedOperatorsTypes
    Author: Vazar & Gemini
    Description:
        Sets the allowed operator class/type filters (Monitor::_allowedOperatorsTypes, PUBLIC GLOBAL FIELD)
        via Monitor::setAllowedOperatorsTypes and disconnects the active operator if no longer allowed.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _allowedOperatorsTypes [String | Number | Array] - Single filter or array of class/type strings or operator IDs (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_allowedOperatorsTypes", []], ["_target", true]];
if !(_allowedOperatorsTypes isEqualTypeAny ["", 1, []]) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setAllowedOperatorsTypes", [_allowedOperatorsTypes], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
