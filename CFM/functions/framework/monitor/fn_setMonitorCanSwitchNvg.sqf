/*
    Function: CFM_fnc_setMonitorCanSwitchNvg
    Author: Vazar & Gemini
    Description:
        Sets whether NVG switching is permitted for the current feed on a monitor instance
        (Monitor::_monitorCanSwitchNvg, PUBLIC GLOBAL FIELD) via Monitor::setMonitorCanSwitchNvg,
        ensuring host actions if enabled or reverting active NVG PiP effect if disabled.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canSwitchNvg [Boolean] - True to allow NVG toggle on the monitor, false to disallow (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canSwitchNvg", false], ["_target", true]];
if !(_canSwitchNvg isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setMonitorCanSwitchNvg", [_canSwitchNvg], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
