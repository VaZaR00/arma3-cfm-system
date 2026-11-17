/*
    Function: CFM_fnc_monitorGrantAccess
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_plrId", ""]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["grantAccess", _plrId] CALL_MON_INST(_monitor, _instId);
