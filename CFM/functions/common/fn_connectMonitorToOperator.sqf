/*
    Function: CFM_fnc_connectMonitorToOperator
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_monitor", "_operator", ["_caller", objNull]];
["connect", [_operator, _caller], _monitor, 0] CALL_OBJCLASS("Monitor", _monitor);
