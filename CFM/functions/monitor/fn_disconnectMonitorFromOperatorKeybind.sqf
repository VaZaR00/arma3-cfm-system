/*
    Function: CFM_fnc_disconnectMonitorFromOperatorKeybind
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

[] call CFM_fnc_exitFullScreen;
[(call CFM_fnc_getTargetMonitor), PLAYER_] call CFM_fnc_disconnectMonitorFromOperator;
