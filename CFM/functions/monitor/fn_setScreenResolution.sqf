/*
    Function: CFM_fnc_setScreenResolution
    Author: Vazar
    Description:
        Sets screen resolution on a monitor object.
*/

#include "defines.hpp"

params [["_monitor", objNull], ["_resolution", ""], ["_global", false]];

if !(IS_OBJ(_monitor)) exitWith {false};

["setScreenResolution", [_resolution, _global]] CALL_OBJCLASS("Monitor", _monitor)
