/*
    Function: CFM_fnc_disconnectMonitorFromOperatorKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

[] call CFM_fnc_exitFullScreen;
private _monPair = GET_MON;
if (IS_VALID_MON(_monPair)) then {
	[_monPair, PLAYER_] call CFM_fnc_disconnectMonitorFromOperator;
};
