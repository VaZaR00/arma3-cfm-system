/*
    Function: CFM_fnc_setMonitorCanFullScreen
    Author: Vazar & Gemini
    Description:
        Enables or disables full-screen mode capability (Monitor::_canFullScreen, PUBLIC GLOBAL FIELD)
        via Monitor::setCanFullScreen, ensuring host actions when enabled or exiting active fullscreen when disabled.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canFullScreen [Boolean] - True to allow full-screen mode, false to forbid (default false).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canFullScreen", false], ["_target", true]];
if !(_canFullScreen isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setCanFullScreen", [_canFullScreen], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
