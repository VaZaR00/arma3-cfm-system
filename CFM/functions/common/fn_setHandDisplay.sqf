/*
    Function: CFM_fnc_setHandDisplay
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_player", PLAYER_], ["_render", true], ["_fullscreen", false]];

private _renderTarget = _player getVariable ["CFM_currentR2T", ""];
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isDialog = _fullscreen || {_isAllHandMonsDialogs || (_player getVariable ["CFM_isHandMonitorDisplay", _isAllHandMonsDialogs])};

if (_render && {IS_VALID_R2T(_renderTarget)}) then {
	private _settings = if (_isDialog) then {
		disableSerialization;
		private _disp = (findDisplay 46) createDisplay "RscDisplayCFM";
		uiNamespace setVariable ["CFM_tabletDisplay", _disp];
		PLAYER_ setVariable ["CFM_tabletDisplayIsOpened", true];
		PLAYER_ setVariable ["CFM_turnedOffLocal", false];
		[_disp, _player] spawn {
			params['_disp', '_player'];
			// for safety
			waitUntil {uiSleep 1; isNull _disp};
			[_player, false] call CFM_fnc_setHandDisplay;
		};
		"[0.9, 0.5, 0.5]"
	} else {
		""
	};
	[_player, _renderTarget, _settings] spawn CFM_fnc_createPIPwindow;
} else {
	if (_isDialog) then {
		private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
		_disp closeDisplay 1;
		uiNamespace setVariable ["CFM_tabletDisplay", displayNull];
	};
	[_player] call CFM_fnc_closePIPwindow;
};
