/*
    Function: CFM_fnc_serverSyncVariables
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_clientId", true]];

["CFM_clientSyncVariables", [
	MGVAR ["CFM_OperatorsIds", createHashMap],
	MGVAR ["CFM_ActiveOperators", []],
	MGVAR ["CFM_ActiveMonitorViewers", []]
], _clientId] call CFM_fnc_remoteEvent;
