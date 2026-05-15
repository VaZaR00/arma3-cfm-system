/*
    Function: CFM_fnc_fpv_getSignal
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", "_operator"];
if !(_operator getVariable ["ArmaFPV_simulateSignal", missionNamespace getVariable ["ArmaFPV_simulateSignal", true]]) exitWith {1};
[_monitor, _operator] call DB_fnc_fpv_getSignal;
