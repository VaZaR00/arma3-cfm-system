/*
    Function: CFM_fnc_checkIfOperatorFeedsToAnyMonitor
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator"];
["checkIfFeedsToAnyMonitor", [], false] CALL_OBJCLASS("Operator", _operator);
