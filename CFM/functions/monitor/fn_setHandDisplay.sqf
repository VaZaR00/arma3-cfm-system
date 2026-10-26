/*
    Function: CFM_fnc_setHandDisplay
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", PLAYER_], ["_render", true], ["_fullscreen", false]];

if !(IS_OBJ(_monitor)) exitWith {};

private _isUI = _monitor getVariable ["CFM_currentFeedIsDisplay", false];
private _renderTarget = _monitor getVariable ["CFM_monitorR2Tid", ""];
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isDialog = _fullscreen || {_isAllHandMonsDialogs || (_monitor getVariable ["CFM_isHandMonitorDisplay", _isAllHandMonsDialogs])};

private _canRender = _render
	&& {IS_VALID_R2T(_renderTarget)}
	&& {_monitor getVariable ["CFM_feedActive", false]}
	&& {!(_monitor getVariable ["CFM_isVehTablet", false]) || {[_monitor] call CFM_fnc_inVehicleTabletSeatCondition}};

if (_canRender) then {
	private _settings = if (_isDialog) then {
		disableSerialization;
		private _prevDisp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
		if (!isNull _prevDisp) then {
			_prevDisp closeDisplay 1;
		};
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", _monitor];
		private _disp = (findDisplay 46) createDisplay "RscDisplayCFMEmpty";
		uiNamespace setVariable ["CFM_tabletDisplay", _disp];
		_monitor setVariable ["CFM_tabletDisplayIsOpened", true];
		_monitor setVariable ["CFM_turnedOffLocal", false];

    	missionNamespace setVariable ["CFM_isInPIPFullScreen", true];
		"[0.9, 0.5, 0.5]"
	} else {
		""
	};
	private _prevPipHndl = _monitor getVariable ["CFM_createPipHndl", scriptNull];
	if (!isNull _prevPipHndl && {!(scriptDone _prevPipHndl)}) then {
		terminate _prevPipHndl;
	};
	private _pipHndl = [_monitor, _renderTarget, _settings, _isUI] spawn CFM_fnc_createPIPwindow;
	_monitor setVariable ["CFM_createPipHndl", _pipHndl];
} else {
	private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
	if (!isNull _disp) then {
		_disp closeDisplay 1;
		uiNamespace setVariable ["CFM_tabletDisplay", displayNull];
	};
	_monitor setVariable ["CFM_tabletDisplayIsOpened", false];
	missionNamespace setVariable ["CFM_isInPIPFullScreen", false];
	[_monitor] call CFM_fnc_closePIPwindow;
};
