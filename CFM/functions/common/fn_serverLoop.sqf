/*
    Function: CFM_fnc_serverLoop
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

while {missionNamespace getVariable ["CFM_doServerLoop", true]} do {
	if (missionNamespace getVariable ["CFM_stopServerLoop", false]) then {continue};
	call CFM_fnc_checkupAllActiveOperators;
	uiSleep CHECK_OP_COND_FREQ;
};
