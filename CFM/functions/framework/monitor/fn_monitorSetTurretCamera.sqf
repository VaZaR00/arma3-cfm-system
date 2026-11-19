/*
    Function: CFM_fnc_monitorSetTurretCamera
    Author: Vazar & Gemini
    Description:
        Switches the connected operator camera on the monitor instance to a specific turret index
        and resets active PiP/NVG effects.
        Wraps Monitor::setTurret (PUBLIC GE GA - State set).
    Parameters:
        0: _monArg [Object | Array] - Monitor object or [monitorObject, instanceId] pair.
        1: _turretIndex [Number | Array] - Target turret index or turret path (default -1).
    Returns:
        [Boolean] - true if turret switch succeeded, false otherwise.
*/

#include "defines.hpp"

params [["_monArg", objNull], ["_turretIndex", -1]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["setTurret", [_turretIndex]] CALL_MON_INST(_monitor, _instId);
