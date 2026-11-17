/*
    Function: CFM_fnc_stopOperatorFeed
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monArg", ["_reset", false], ["_isOptimize", false]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["stopFeed", [_reset, _isOptimize]] CALL_MON_INST(_monitor, _instId);
