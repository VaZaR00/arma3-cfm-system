/*
    Function: CFM_fnc_setMonitorPiPEffect
    Author: Vazar & Gemini
    Description:
        Sets the PiP visual effect (normal, NVG, TI) on a monitor instance render target
        via Monitor::setPiPEffect and distributes execution via CFM remoteEvent (REMOTE_EXEC_OBJINSTANCE).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _pipEffect [Number] - PiP effect index (0 = Normal, 1 = NVG, 2+ = TI modes) (default 0).
        2: _target [Boolean | Number | Object | Array] - MP execution target (true = global, false = local) (default true).
    Returns:
        [Boolean | String] - true when executed locally, JIP ID if global, or false on invalid arguments.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_pipEffect", 0], ["_target", true]];
if !(_pipEffect isEqualType 0) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
if (_target isNotEqualTo false && {MON_GVAR(_monitor, _instId, "CFM_isLocal", false)}) then {_target = false};
["setPiPEffect", [_pipEffect], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
