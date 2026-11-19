/*
    Function: CFM_fnc_setMonitorSeatDisplayName
    Author: Vazar & Gemini
    Description:
        Sets the localized/readable seat display name (Monitor::_seatDisplayName, PUBLIC LOCAL FIELD)
        via Monitor::setSeatDisplayName and rebuilds menu action labels.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatDisplayName [String] - Display name for the seat(s) (default "").
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatDisplayName", ""], ["_target", true]];
if !(_seatDisplayName isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setSeatDisplayName", [_seatDisplayName], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
