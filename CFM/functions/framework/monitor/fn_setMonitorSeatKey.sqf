/*
    Function: CFM_fnc_setMonitorSeatKey
    Author: Vazar & Gemini
    Description:
        Sets the primary vehicle seat key (Monitor::_seatKey, PUBLIC GLOBAL FIELD) via Monitor::setSeatKey
        and refreshes seat display names and action labels.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatKey [String] - Seat key identifier (e.g. "driver", "cargo_0", "turret_[0]") (default "").
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatKey", ""], ["_target", true]];
if !(_seatKey isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setSeatKey", [_seatKey], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
