/*
    Function: CFM_fnc_setMonitorIsHandTablet
    Author: Vazar & Gemini
    Description:
        Sets whether the monitor instance is a player handheld UAV tablet (Monitor::_isHandTablet, PUBLIC GLOBAL FIELD).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _isHandTablet [Boolean] - True if handheld tablet, false otherwise (default false).
        2: _target [Boolean | Number | Object | Array] - MP sync target (true = global, false = local) (default true).
    Returns:
        [Boolean] - true if set successfully, false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_isHandTablet", false], ["_target", true]];
if !(_isHandTablet isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _syncTarget = RESOLVE_SVAR_TARGET(_target);
MON_SVARG(_monitor, _instId, "CFM_isHandTablet", _isHandTablet, _syncTarget);
true
