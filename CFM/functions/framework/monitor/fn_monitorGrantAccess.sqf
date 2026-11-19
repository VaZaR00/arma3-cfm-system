/*
    Function: CFM_fnc_monitorGrantAccess
    Author: Vazar & Gemini
    Description:
        Grants password access on a monitor instance to the specified player UID/ID.
        Wraps Monitor::grantAccess (PUBLIC GE GA - Config set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _plrId [String] - Player UID or identifier string to add to the access list.
    Returns:
        [Boolean] - false on invalid monitor, otherwise nil/void.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_plrId", ""]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["grantAccess", [_plrId]] CALL_MON_INST(_monitor, _instId);
