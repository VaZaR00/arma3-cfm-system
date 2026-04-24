/*
    Function: CFM_fnc_onDisplayUnload
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_display", displayNull]];
disableSerialization;
private _currentFullscreenedMonitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", PLAYER_];
_currentFullscreenedMonitor setVariable ["CFM_tabletDisplayIsOpened", false];
if (_currentFullscreenedMonitor isEqualTo PLAYER_) then {
	[PLAYER_] call CFM_fnc_turnOffMonitorLocal;
} else {
	[_currentFullscreenedMonitor, false] call CFM_fnc_setHandDisplay;
};
if (missionNamespace getVariable ["CFM_isInFullScreen", false]) then {
	[] call CFM_fnc_exitFullScreen;
};
missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
