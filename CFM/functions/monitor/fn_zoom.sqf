/*
    Function: CFM_fnc_zoom
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_monitor", 0], ["_zoomAdd", 0], ["_zoomSet", -1], ["_isContinuous", false]];

["zoom", [_zoomAdd, _zoomSet, _isContinuous]] CALL_OBJCLASS("Monitor", _monitor);
