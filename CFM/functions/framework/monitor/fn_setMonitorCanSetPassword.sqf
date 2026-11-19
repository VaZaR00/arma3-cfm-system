/*
    Function: CFM_fnc_setMonitorCanSetPassword
    Author: Vazar & Gemini
    Description:
        Enables or disables password protection capability (Monitor::_canSetPassword, PUBLIC GLOBAL FIELD)
        via Monitor::setCanSetPassword.
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _canSetPassword [Boolean] - True to allow password protection, false to disable (default true).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_canSetPassword", true], ["_target", true]];
if !(_canSetPassword isEqualType false) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setCanSetPassword", [_canSetPassword], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
