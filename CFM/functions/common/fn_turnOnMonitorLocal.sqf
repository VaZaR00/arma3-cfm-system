/*
    Function: CFM_fnc_turnOnMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor"];
[_monitor] call CFM_fnc_setMonitorTexture;
_monitor setVariable ["CFM_turnedOffLocal", false];
