/*
    Function: CFM_fnc_onTempDisplayUnload
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_display", displayNull]];
disableSerialization;
private _currentFullscreenedMonitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", PLAYER_];
_currentFullscreenedMonitor setVariable ["CFM_tabletDisplayIsOpened", false];

[_currentFullscreenedMonitor] spawn CFM_fnc_resetFeed;

if (missionNamespace getVariable ["CFM_isInFullScreen", false]) then {
	[] call CFM_fnc_exitFullScreen;
};
missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];
