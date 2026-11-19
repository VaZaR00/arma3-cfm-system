/*
    Function: CFM_fnc_setMonitorSides
    Author: Vazar & Gemini
    Description:
        Sets the allowed sides filter (Monitor::_monitorSides, PUBLIC GLOBAL FIELD) via Monitor::setMonitorSides
        and disconnects the active operator if it no longer meets the side filter.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _sides [Side | Array] - Side or array of Sides (west, east, independent, civilian) (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_sides", []], ["_target", true]];
if !(_sides isEqualTypeAny [west, []]) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setMonitorSides", [_sides], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
