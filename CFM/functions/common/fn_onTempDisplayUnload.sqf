/*
    Function: CFM_fnc_onTempDisplayUnload
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_display", displayNull]];
disableSerialization;

missionNamespace setVariable ["CFM_isInPIPFullScreen", false];
uiNamespace setVariable ["CFM_tabletDisplay", displayNull];

private _currentFullscreenedMonitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", objNull];
missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];

if (missionNamespace getVariable ["CFM_isInFullScreen", false]) then {
	[] call CFM_fnc_exitFullScreen;
};

if !(IS_OBJ(_currentFullscreenedMonitor)) exitWith {
	[PLAYER_] call CFM_fnc_closePIPwindow;
};

_currentFullscreenedMonitor setVariable ["CFM_tabletDisplayIsOpened", false];

if !(_currentFullscreenedMonitor getVariable ["CFM_feedActive", false]) exitWith {
	[_currentFullscreenedMonitor] call CFM_fnc_closePIPwindow;
};

private _isHandMonitor = _currentFullscreenedMonitor getVariable ["CFM_isHandMonitor", false];
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isAlwaysDialog = _isAllHandMonsDialogs || (_currentFullscreenedMonitor getVariable ["CFM_isHandMonitorDisplay", _isAllHandMonsDialogs]);

if (_isHandMonitor && _isAlwaysDialog) exitWith {
	[_currentFullscreenedMonitor] call CFM_fnc_turnOffMonitorLocal;
};

[_currentFullscreenedMonitor] call CFM_fnc_closePIPwindow;
[_currentFullscreenedMonitor] spawn {
	params ["_mon"];
	uiSleep 0.02;
	[_mon] spawn CFM_fnc_resetFeed;
};
