/*
    Function: CFM_fnc_setMonitorCurrentCameraCanMove
    Author: Vazar & Gemini
    Description:
        Sets whether the player can rotate/move the currently streamed camera from this monitor instance
        (Monitor::_currentCameraCanMove, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canMove [Boolean] - True to allow remote camera movement, false to lock it (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canMove", false], ["_target", true]];
if !(_canMove isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_currentCameraCanMove", _canMove, _syncTarget);
true
