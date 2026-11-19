/*
    Function: CFM_fnc_setMonitorSeatKeys
    Author: Vazar & Gemini
    Description:
        Sets the array of vehicle seat keys (Monitor::_seatKeys, PUBLIC GLOBAL FIELD) via Monitor::setSeatKeys
        and refreshes seat display names and action labels.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatKeys [Array] - Array of seat key strings (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatKeys", []], ["_target", true]];
if !(_seatKeys isEqualType []) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setSeatKeys", [_seatKeys], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
