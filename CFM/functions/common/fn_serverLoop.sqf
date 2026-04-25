/*
    Function: CFM_fnc_serverLoop
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !(isServer) exitWith {};

if (isNil "CFM_SERVER_CHECK_FOR_NEW_OPERATORS_EC_EH_id") then {
	CFM_SERVER_CHECK_FOR_NEW_OPERATORS_EC_EH_id = addMissionEventHandler ["EntityCreated", {
		params ["_entity"];
		if !(MGVAR ["CFM_SERVER_DO_CHECK_FOR_NEW_OPERATORS", true]) exitWith {};

		[_entity] call CFM_fnc_checkIfNewOperator;
	}];
};

while {missionNamespace getVariable ["CFM_doServerLoop", true]} do {
	if (missionNamespace getVariable ["CFM_stopServerLoop", false]) then {continue};
	call CFM_fnc_checkupAllActiveOperators;
	uiSleep CHECK_OP_COND_FREQ;
};
