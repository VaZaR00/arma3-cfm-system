/*
    Function: CFM_fnc_setHandDisplay
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monArg", PLAYER_], ["_render", true], ["_fullscreen", false]];

(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {};
private _monPair = [_monitor, _instId];

private _isUI = MON_GVAR(_monitor, _instId, "CFM_currentFeedIsDisplay", false);
private _renderTarget = MON_GVAR(_monitor, _instId, "CFM_monitorR2Tid", "");
private _isAllHandMonsDialogs = missionNamespace getVariable ["CFM_allHandMonitorsAreDisplays", false];
private _isDialog = _fullscreen || {_isAllHandMonsDialogs || (MON_GVAR(_monitor, _instId, "CFM_isHandMonitorDisplay", _isAllHandMonsDialogs))};

private _canRender = _render
	&& {IS_VALID_R2T(_renderTarget)}
	&& {MON_GVAR(_monitor, _instId, "CFM_feedActive", false)}
	&& {!(MON_GVAR(_monitor, _instId, "CFM_isVehSeatTablet", false)) || {[_monitor, _instId] call CFM_fnc_inVehicleTabletSeatCondition}};

if (_canRender) then {
	private _settings = if (_isDialog) then {
		disableSerialization;
		private _prevDisp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
		if (!isNull _prevDisp) then {
			_prevDisp closeDisplay 1;
		};
		missionNamespace setVariable ["CFM_currentFullScreenMonitor", _monPair];
		private _disp = if (missionNamespace getVariable ["CFM_blockMovementInFullscreen", false]) then {
			createDialog "RscDisplayCFMEmpty";
			findDisplay 167
		} else {
			(findDisplay 46) createDisplay "RscDisplayCFMEmpty"
		};
		uiNamespace setVariable ["CFM_tabletDisplay", _disp];
		MON_SVAR(_monitor, _instId, "CFM_tabletDisplayIsOpened", true);
		MON_SVAR(_monitor, _instId, "CFM_turnedOffLocal", false);

    	missionNamespace setVariable ["CFM_isInPIPFullScreen", true];
		[_monPair] call CFM_fnc_playHandTabletAnim;
		"[0.9, 0.5, 0.5]"
	} else {
		""
	};
	private _prevPipHndl = MON_GVAR(_monitor, _instId, "CFM_createPipHndl", scriptNull);
	if (!isNull _prevPipHndl && {!(scriptDone _prevPipHndl)}) then {
		terminate _prevPipHndl;
	};
	private _pipHndl = [_monPair, _renderTarget, _settings, _isUI] spawn CFM_fnc_createPIPwindow;
	MON_SVAR(_monitor, _instId, "CFM_createPipHndl", _pipHndl);
} else {
	if (dialog) then {
		closeDialog 0;
	};
	private _disp = uiNamespace getVariable ["CFM_tabletDisplay", displayNull];
	if (!isNull _disp) then {
		_disp closeDisplay 1;
		uiNamespace setVariable ["CFM_tabletDisplay", displayNull];
	};
	private _fallbackDisp = findDisplay 167;
	if (!isNull _fallbackDisp) then {
		_fallbackDisp closeDisplay 1;
	};
	MON_SVAR(_monitor, _instId, "CFM_tabletDisplayIsOpened", false);
	missionNamespace setVariable ["CFM_isInPIPFullScreen", false];
	[_monPair] call CFM_fnc_closePIPwindow;
};
