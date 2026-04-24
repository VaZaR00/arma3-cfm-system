/*
    Function: CFM_fnc_turnOnOffMonitorLocalKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

[] call CFM_fnc_exitFullScreen;
if (_this call CFM_fnc_turnOffActionCondition) then {
	_this call CFM_fnc_turnOffMonitorLocal;
} else {
	_this call CFM_fnc_turnOnMonitorLocal;
};
