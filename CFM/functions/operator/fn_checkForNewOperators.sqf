/*
    Function: CFM_fnc_checkForNewOperators
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", objNull]];

[_monitor] call CFM_fnc_monitorCloseMenu;

if !(isServer) exitWith {
	[_monitor, {_this call CFM_fnc_checkForNewOperators}, 2, false, false] call CFM_fnc_remoteExec;
};

{
    [_x] call CFM_fnc_checkIfNewOperator
} forEach vehicles;