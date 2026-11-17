/*
    Function: CFM_fnc_zoom
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_monArg", 0], ["_zoomAdd", 0], ["_zoomSet", -1], ["_isContinuous", false]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
["zoom", [_zoomAdd, _zoomSet, _isContinuous]] CALL_MON_INST(_monitor, _instId);
