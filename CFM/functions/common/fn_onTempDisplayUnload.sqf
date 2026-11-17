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

private _currentFullscreenedMonArg = missionNamespace getVariable ["CFM_currentFullScreenMonitor", [objNull, -1]];

if (missionNamespace getVariable ["CFM_isInFullScreen", false]) exitWith {
	[] call CFM_fnc_exitFullScreen;
};

missionNamespace setVariable ["CFM_currentFullScreenMonitor", nil];

(RESOLVE_MON(_currentFullscreenedMonArg)) params ["_monObj", "_monInstId"];
if (!(IS_OBJ(_monObj)) || {_monInstId < 1}) exitWith {
	private _handInst = (PLAYER_ getVariable ["CFM_monitorInstancesMap", createHashMap]) getOrDefault [HAND_MONITOR_KEY, 1];
	[[PLAYER_, _handInst]] call CFM_fnc_closePIPwindow;
};

private _monPair = [_monObj, _monInstId];
MON_SVAR(_monObj, _monInstId, "CFM_tabletDisplayIsOpened", false);

if !(MON_GVAR(_monObj, _monInstId, "CFM_feedActive", false)) exitWith {
	[_monPair] call CFM_fnc_closePIPwindow;
};

private _isHandMonitor = MON_GVAR(_monObj, _monInstId, "CFM_isHandMonitor", false);
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isAlwaysDialog = _isAllHandMonsDialogs || (MON_GVAR(_monObj, _monInstId, "CFM_isHandMonitorDisplay", _isAllHandMonsDialogs));

if !(_isHandMonitor) exitWith {
	[_monPair] call CFM_fnc_closePIPwindow;
};

if (_isAlwaysDialog) exitWith {
	[_monPair] call CFM_fnc_turnOffMonitorLocal;
};

if !([_monPair] call CFM_fnc_updatePipWindowPosition) then {
	[_monPair, true] call CFM_fnc_setHandDisplay;
};
