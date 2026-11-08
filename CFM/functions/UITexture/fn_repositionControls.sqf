/*
    Function: CFM_fnc_repositionControls
    Author: Vazar
    Description:
        Evaluates cached control formulas for the given display and monitor ScreenResolution,
        and repositions/resizes all controls of the display on load.
*/

#include "defines.hpp"

#ifdef FINAL
#define UI_CACHE_NAMESPACE parsingNamespace
#else
#define UI_CACHE_NAMESPACE missionNamespace
#endif

params [
	["_display", displayNull, [displayNull]],
	["_displayClass", "", [""]],
	["_monitor", objNull, [objNull]]
];

if (isNull _display) exitWith {false};

if (IS_OBJ(_monitor)) then {
	_display setVariable ["CFM_monitor", _monitor];
};

if (_displayClass isEqualTo "") then {
	_displayClass = _display getVariable ["CFM_displayClass", ""];
};
if (_displayClass isEqualTo "") exitWith {false};

_display setVariable ["CFM_displayClass", _displayClass];

private _allDisplaysCache = UI_CACHE_NAMESPACE getVariable "CFM_displaysControlsCache";
private _controlsCache = if (!isNil "_allDisplaysCache") then {
	_allDisplaysCache get _displayClass
} else {
	nil
};

if (isNil "_controlsCache" || {count _controlsCache == 0}) then {
	_controlsCache = [_displayClass] call CFM_fnc_parseDisplayConfig;
};

if (isNil "_controlsCache" || {count _controlsCache == 0}) exitWith {false};

private _res = [_display] call CFM_fnc_getMonitorScreenResolution;

private _fnc_applyCtrl = {
	params ["_idc", "_ctrlData"];

	private _parentIdc = _ctrlData getOrDefault ["parentIdc", -1];
	private _ctrl = if (_parentIdc >= 0) then {
		private _grpCtrl = _display displayCtrl _parentIdc;
		if !(isNull _grpCtrl) then {
			_grpCtrl controlsGroupCtrl _idc
		} else {
			_display displayCtrl _idc
		}
	} else {
		_display displayCtrl _idc
	};
	if (isNull _ctrl) then {
		_ctrl = _display displayCtrl _idc;
	};
	if (isNull _ctrl) exitWith {};

	(ctrlPosition _ctrl) params [["_curX", 0], ["_curY", 0], ["_curW", 0], ["_curH", 0]];

	private _xCode = _ctrlData get "x";
	private _yCode = _ctrlData get "y";
	private _wCode = _ctrlData get "w";
	private _hCode = _ctrlData get "h";

	private _newX = if (!isNil "_xCode") then {call _xCode} else {_curX};
	private _newY = if (!isNil "_yCode") then {call _yCode} else {_curY};
	private _newW = if (!isNil "_wCode") then {call _wCode} else {_curW};
	private _newH = if (!isNil "_hCode") then {call _hCode} else {_curH};

	_ctrl ctrlSetPosition [_newX, _newY, _newW, _newH];

	private _sizeCode = _ctrlData get "size";
	if (isNil "_sizeCode") then {
		_sizeCode = _ctrlData get "sizeEx";
	};
	if (!isNil "_sizeCode") then {
		private _newSize = call _sizeCode;
		if (!isNil "_newSize" && {_newSize isEqualType 0}) then {
			_ctrl ctrlSetFontHeight _newSize;
		};
	};

	_ctrl ctrlCommit 0;
};

// Pass 1: Reposition top-level controls and controlsGroups first
{
	if ((_y getOrDefault ["parentIdc", -1]) < 0) then {
		[_x, _y] call _fnc_applyCtrl;
	};
} forEach _controlsCache;

// Pass 2: Reposition child controls inside controlsGroups
{
	if ((_y getOrDefault ["parentIdc", -1]) >= 0) then {
		[_x, _y] call _fnc_applyCtrl;
	};
} forEach _controlsCache;

true
