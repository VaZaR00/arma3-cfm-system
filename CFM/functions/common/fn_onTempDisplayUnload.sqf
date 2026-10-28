/*
    Function: CFM_fnc_onTempDisplayUnload
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_display", displayNull]];
disableSerialization;

private _wasInPipFullScreen = missionNamespace getVariable ["CFM_isInPIPFullScreen", false];
missionNamespace setVariable ["CFM_isInPIPFullScreen", false];
uiNamespace setVariable ["CFM_tabletDisplay", displayNull];

private _currentFullscreenedMonitor = missionNamespace getVariable ["CFM_currentFullScreenMonitor", objNull];

if (missionNamespace getVariable ["CFM_isInFullScreen", false]) exitWith {
	[] call CFM_fnc_exitFullScreen;
};

missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];

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

if !(_isHandMonitor) exitWith {
	[_currentFullscreenedMonitor] call CFM_fnc_closePIPwindow;
};

if (_isAlwaysDialog) exitWith {
	[_currentFullscreenedMonitor] call CFM_fnc_turnOffMonitorLocal;
};

if !([_currentFullscreenedMonitor] call CFM_fnc_updatePipWindowPosition) then {
	[_currentFullscreenedMonitor, true] call CFM_fnc_setHandDisplay;
};
