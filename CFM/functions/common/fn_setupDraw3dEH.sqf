/*
    Function: CFM_fnc_setupDraw3dEH
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if (isNil "CFM_UPD_CLIENT_EH_id") then {
	if !(hasInterface) exitWith {};
	private _func = {call CFM_fnc_onEachFrameClient};
	if (true) then {
		_func = {call CFM_fnc_onEachFrameClient; call CFM_fnc_updateOperator};
	};
	CFM_UPD_CLIENT_EH_id = addMissionEventHandler ["EachFrame", _func];
};
