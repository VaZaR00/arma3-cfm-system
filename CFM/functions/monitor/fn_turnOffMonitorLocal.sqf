/*
    Function: CFM_fnc_turnOffMonitorLocal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor"];

["toggleMonitorLocal", false] CALL_OBJCLASS("DisplayHandler", _monitor);
