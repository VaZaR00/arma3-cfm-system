/*
    Function: CFM_fnc_setOperatorInfo
    Author: Vazar & Gemini
    Description:
        Updates the formatted operator info label on a monitor instance and syncs the action text
        if the instance is currently selected on the monitor host.
        Wraps Monitor::setOperatorInfo (PUBLIC LE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _set [Boolean] - True to show connected operator info, false to reset to default title (default false).
        2: _operator [Object] - Optional operator object override (defaults to monitor's connected operator).
        3: _target [Boolean | Number | Object | Array] - Remote execution target (true = global, false = local) (default true).
    Returns:
        [String | Boolean] - Formatted info string when executed locally, or false on invalid monitor.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_set", false], ["_operator", nil], ["_target", true]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["setOperatorInfo", [_set, _NIL(_operator)], _target, false] REMOTE_EXEC_OBJINSTANCE("Monitor", _instId, _monitor);
