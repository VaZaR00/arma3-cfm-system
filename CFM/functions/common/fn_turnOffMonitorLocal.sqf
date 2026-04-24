/*
    Function: CFM_fnc_turnOffMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor"];
[_monitor, false, "", true] call CFM_fnc_setMonitorTexture;
_monitor setVariable ["CFM_turnedOffLocal", true];
