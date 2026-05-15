/*
    Function: CFM_fnc_getOperatorName
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator", ["_turret", -1]];
["getOperatorName", [_turret], ""] CALL_OBJCLASS("Operator", _operator);
