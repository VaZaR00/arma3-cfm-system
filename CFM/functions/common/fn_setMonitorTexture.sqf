/*
    Function: CFM_fnc_setMonitorTexture
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_render", true], ["_r2t", ""], ["_turnOff", false]];

["setRenderPicture", [_render, _r2t, _turnOff]] CALL_OBJCLASS("Monitor", _monitor);
