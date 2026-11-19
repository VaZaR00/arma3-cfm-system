/*
    Function: CFM_fnc_setMonitorControlSeatKeys
    Author: Vazar & Gemini
    Description:
        Sets the array of seat keys (Monitor::_controlSeatKeys, PUBLIC GLOBAL FIELD) permitted to control
        a shared vehicle monitor instance via Monitor::setControlSeatKeys, closing any unauthorized open menu.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _controlSeatKeys [Array] - Array of controlling seat key strings (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_controlSeatKeys", []], ["_target", true]];
if !(_controlSeatKeys isEqualType []) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setControlSeatKeys", [_controlSeatKeys], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
