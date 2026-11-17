/*
    Function: CFM_fnc_turnOffMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg"];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _dhId = MON_GVAR(_monitor, _instId, "CFM_displayHandlerId", -1);
if (_dhId < 1) exitWith {false};
["toggleMonitorLocal", false] CALL_DH_INST(_monitor, _dhId);
