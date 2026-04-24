/*
    Function: CFM_fnc_zoom
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params [["_monitor", 0], ["_zoomAdd", 0], ["_zoomSet", -1]];

["zoom", [_zoomAdd, _zoomSet]] CALL_OBJCLASS("Monitor", _monitor);
