/*
    Function: CFM_fnc_setMonitorCurrentCameraSmoothZoom
    Author: Vazar & Gemini
    Description:
        Sets whether zoom transitions are smoothed (interpolated) for the current camera feed
        on a monitor instance (Monitor::_currentCameraSmoothZoom, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _smoothZoom [Boolean] - True for smooth FOV interpolation, false for instant zoom (default true).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_smoothZoom", true], ["_target", true]];
if !(_smoothZoom isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_currentCameraSmoothZoom", _smoothZoom, _syncTarget);
true
