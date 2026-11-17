/*
    Function: CFM_fnc_monitorToggleNVG
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg"];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["switchNvg"] CALL_MON_INST(_monitor, _instId);
