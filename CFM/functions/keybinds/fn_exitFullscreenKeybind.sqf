/*
    Function: CFM_fnc_exitFullscreenKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

if !((missionNamespace getVariable ["CFM_isInFullScreen", false]) || (missionNamespace getVariable ["CFM_isInPIPFullScreen", false])) exitWith {};

private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
if (!isNull _disp) then {
	_disp closeDisplay 1;
} else {
	call CFM_fnc_onTempDisplayUnload;
};
