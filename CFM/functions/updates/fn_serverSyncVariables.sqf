/*
    Function: CFM_fnc_serverSyncVariables
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_clientId", true]];

[[
	MGVAR ["CFM_Operators", []],
	MGVAR ["CFM_Monitors", []],
	MGVAR ["CFM_OperatorsIds", createHashMap],
	MGVAR ["CFM_ActiveOperators", []],
	MGVAR ["CFM_ActiveMonitorViewers", []]
], {
	isNil {
		missionNamespace setVariable ["CFM_Operators", _this param [0, []]];
		missionNamespace setVariable ["CFM_Monitors", _this param [1, []]];
		missionNamespace setVariable ["CFM_OperatorsIds", _this param [2, createHashMap]];
		missionNamespace setVariable ["CFM_ActiveOperators", _this param [3, []]];
		missionNamespace setVariable ["CFM_ActiveMonitorViewers", _this param [4, []]];
	};
}, _clientId, false, true] call CFM_fnc_remoteExec;
