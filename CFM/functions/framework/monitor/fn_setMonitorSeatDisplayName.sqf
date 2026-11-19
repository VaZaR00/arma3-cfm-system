/*
    Function: CFM_fnc_setMonitorSeatDisplayName
    Author: Vazar & Gemini
    Description:
        Sets the localized/readable seat display name (Monitor::_seatDisplayName, PUBLIC LOCAL FIELD) shown in monitor actions.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _seatDisplayName [String] - Display name for the seat(s) (default "").
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_seatDisplayName", ""], ["_target", true]];
if !(_seatDisplayName isEqualType "") exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_seatDisplayName", _seatDisplayName, _syncTarget);
true
