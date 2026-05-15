/*
    Function: CFM_fnc_operatorMonitorDisconnectedEvent
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator", "_monitor", ["_turret", -1]];
["monitorDisconnectedLocalOperator", [_monitor, _turret]] CALL_OBJCLASS("Operator", _operator);
