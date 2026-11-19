/*
    Function: CFM_fnc_setMonitorCurrentCameraMoveRestrictions
    Author: Vazar & Gemini
    Description:
        Sets angular movement restrictions [upDeg, downDeg, leftDeg, rightDeg] for the current camera
        on a monitor instance (Monitor::_currentCameraMoveRestrictions, PUBLIC GLOBAL FIELD)
        via Monitor::setCurrentCameraMoveRestrictions.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _restrictions [Array] - Array [up, down, left, right] in degrees (default []).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_restrictions", []], ["_target", true]];
if !(_restrictions isEqualType []) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setCurrentCameraMoveRestrictions", [_restrictions], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
