/*
    Function: CFM_fnc_setMonitorCurrentCameraMoveRestrictions
    Author: Vazar & Gemini
    Description:
        Sets angular movement restrictions [upDeg, downDeg, leftDeg, rightDeg] for the current camera
        on a monitor instance (Monitor::_currentCameraMoveRestrictions, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _restrictions [Array] - Array [up, down, left, right] in degrees (default []).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_restrictions", []], ["_target", true]];
if !(_restrictions isEqualType []) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_currentCameraMoveRestrictions", _restrictions, _syncTarget);
true
