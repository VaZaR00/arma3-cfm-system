/*
    Function: CFM_fnc_setMonitorAllowedOperators
    Author: Vazar & Gemini
    Description:
        Sets the whitelist of specific operator objects (Monitor::_allowedOperators, PUBLIC GLOBAL FIELD)
        via Monitor::setAllowedOperators and disconnects the active operator if no longer allowed.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _allowedOperators [Object | Array] - Operator object or array of operator objects (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_allowedOperators", []], ["_target", true]];
if !(_allowedOperators isEqualTypeAny [objNull, []]) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setAllowedOperators", [_allowedOperators], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
