/*
    Function: CFM_fnc_getActiveOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];
(missionNamespace getVariable ["CFM_Operators", []]) select {[_x, _monitor] call CFM_fnc_operatorCondition};
