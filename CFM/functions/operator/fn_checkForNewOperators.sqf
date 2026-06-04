/*
    Function: CFM_fnc_checkForNewOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];

[_monitor] call CFM_fnc_monitorCloseMenu;

if !(isServer) exitWith {
	["CFM_checkForNewOperators", _monitor, 2] call CFM_fnc_remoteEvent;
};

{
    [_x] call CFM_fnc_checkIfNewOperator
} forEach vehicles;