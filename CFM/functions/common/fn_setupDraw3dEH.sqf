/*
    Function: CFM_fnc_setupDraw3dEH
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if (isNil "CFM_UPD_CLIENT_EH_id") then {
	private _func = {[] call CFM_fnc_updateLocalOperators};
	if (hasInterface) then {
		_func = {call CFM_fnc_onEachFrameClient; [] call CFM_fnc_updateLocalOperators};
	};
	CFM_UPD_CLIENT_EH_id = addMissionEventHandler ["EachFrame", _func];
};
