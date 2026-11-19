/*
    Function: CFM_fnc_setMonitorIsHandTablet
    Author: Vazar & Gemini
    Description:
        Sets whether the monitor instance is a player handheld UAV tablet (Monitor::_isHandTablet, PUBLIC GLOBAL FIELD)
        via Monitor::setIsHandTablet and updates hand-monitor flags and action labels.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _isHandTablet [Boolean] - True if handheld tablet, false otherwise (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_isHandTablet", false], ["_target", true]];
if !(_isHandTablet isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setIsHandTablet", [_isHandTablet], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
