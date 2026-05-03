/*
    Function: CFM_fnc_disconnectMonitorFromOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor", ["_caller", objNull]];
["disconnect", [_caller]] CALL_OBJCLASS("Monitor", _monitor);
