/*
    Function: CFM_fnc_setMonitorSeatKey
    Author: Vazar & Gemini
    Description:
        Sets the primary vehicle seat key (Monitor::_seatKey, PUBLIC GLOBAL FIELD) bound to a monitor instance.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatKey [String] - Seat key identifier (e.g. "driver", "cargo_0", "turret_[0]") (default "").
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatKey", ""], ["_target", true]];
if !(_seatKey isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_seatKey", _seatKey, _syncTarget);
true
