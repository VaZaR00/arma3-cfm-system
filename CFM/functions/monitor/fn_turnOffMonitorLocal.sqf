/*
    Function: CFM_fnc_turnOffMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor"];
[_monitor, false, "", true] call CFM_fnc_setR2TTexture;
_monitor setVariable ["CFM_turnedOffLocal", true];
