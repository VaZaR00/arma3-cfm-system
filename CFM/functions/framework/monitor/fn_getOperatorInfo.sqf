/*
    Function: CFM_fnc_getOperatorInfo
    Author: Vazar & Gemini
    Description:
        Displays detailed hint information about the operator currently connected to the monitor instance
        (operator name, map grid, distance, and active turret index).
        Wraps Monitor::getOperatorInfo (PUBLIC LOCAL - State get).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
    Returns:
        [Nil]
*/

#include "defines.hpp"

params [["_monArg", objNull]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {};
["getOperatorInfo", [], []] CALL_MON_INST(_monitor, _instId);
