/*
    Function: CFM_fnc_setHandDisplay
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", PLAYER_], ["_render", true], ["_fullscreen", false]];

private _isUI = _monitor getVariable ["CFM_currentFeedIsDisplay", false];
private _renderTarget = _monitor getVariable ["CFM_monitorR2Tid", ""];
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isDialog = _fullscreen || {_isAllHandMonsDialogs || (_monitor getVariable ["CFM_isHandMonitorDisplay", _isAllHandMonsDialogs])};

if (_render && {IS_VALID_R2T(_renderTarget)}) then {
	private _settings = if (_isDialog) then {
		disableSerialization;
		private _disp = (findDisplay 46) createDisplay "RscDisplayCFMEmpty";
		uiNamespace setVariable ["CFM_tabletDisplay", _disp];
		PLAYER_ setVariable ["CFM_tabletDisplayIsOpened", true];
		PLAYER_ setVariable ["CFM_turnedOffLocal", false];

		// null display nadler
		// private _nullDispHndl = [_disp, _monitor] spawn {
		// 	// for safety
		// 	params['_disp', '_monitor'];
		// 	private _prevHndl = _monitor getVariable ["CFM_pip_nullDispHndl", scriptNull];

		// 	if !(scriptDone _prevHndl) then {
		// 		terminate _prevHndl;
		// 		waitUntil {uiSleep 0.1; scriptDone _prevHndl};
		// 	};

		// 	_monitor setVariable ["CFM_pip_nullDispHndl", _thisScript];

		// 	waitUntil {uiSleep 1; isNull _disp};
		// 	_disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
		// 	if !(isNull _disp) exitWith {};
		// 	[_monitor, false] call CFM_fnc_setHandDisplay;
		// };

    	missionNamespace setVariable ["CFM_isInPIPFullScreen", true];
		"[0.9, 0.5, 0.5]"
	} else {
		""
	};
	[_monitor, _renderTarget, _settings, _isUI] spawn CFM_fnc_createPIPwindow;
} else {
	if (_isDialog) then {
		private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
		_disp closeDisplay 1;
		uiNamespace setVariable ["CFM_tabletDisplay", displayNull];
	};
	missionNamespace setVariable ["CFM_isInPIPFullScreen", false];	
	[_monitor] call CFM_fnc_closePIPwindow;
};
