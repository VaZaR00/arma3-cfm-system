/*
    Function: CFM_fnc_turnOnMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor"];

["toggleMonitorLocal", true] CALL_OBJCLASS("DisplayHandler", _monitor);
