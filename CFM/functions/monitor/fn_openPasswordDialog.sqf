/*
    Function: CFM_fnc_openPasswordDialog
    Author: Vazar
    Description: Opens a minimal password input dialog for setting, changing, or entering a monitor password.
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_mode", "enter"],
	["_caller", player],
	["_target", objNull]
];

if !(hasInterface) exitWith {};
if !(IS_OBJ(_monitor)) exitWith {};
if (isNull _target) then {_target = _monitor};

if !(canSuspend) exitWith {
	_this spawn CFM_fnc_openPasswordDialog;
};

disableSerialization;

private _parentDisplay = findDisplay 46;
if (isNull _parentDisplay) exitWith {};

private _display = _parentDisplay createDisplay "RscDisplayEmpty";
if (isNull _display) exitWith {};

private _w = 0.30;
private _h = 0.15;
private _x = 0.5 - (_w / 2);
private _y = 0.5 - (_h / 2);

private _bg = _display ctrlCreate ["RscText", -1];
_bg ctrlSetPosition [_x, _y, _w, _h];
_bg ctrlSetBackgroundColor [0.08, 0.08, 0.08, 0.92];
_bg ctrlCommit 0;

private _titleText = switch (_mode) do {
	case "set": {CFM_STR_SET_PASSWORD};
	case "change": {CFM_STR_CHANGE_PASSWORD};
	default {CFM_STR_ENTER_PASSWORD};
};

private _title = _display ctrlCreate ["RscText", -1];
_title ctrlSetPosition [_x, _y, _w, 0.035];
_title ctrlSetBackgroundColor [0.18, 0.18, 0.18, 0.96];
_title ctrlSetText _titleText;
_title ctrlCommit 0;

private _edit = _display ctrlCreate ["RscEdit", 101];
_edit ctrlSetPosition [_x + 0.015, _y + 0.048, _w - 0.03, 0.038];
_edit ctrlSetBackgroundColor [0, 0, 0, 0.75];
_edit ctrlSetTextColor [1, 1, 1, 1];
_edit ctrlCommit 0;

private _btnW = (_w - 0.04) / 2;
private _btnY = _y + 0.098;

private _btnCancel = _display ctrlCreate ["RscButton", 102];
_btnCancel ctrlSetPosition [_x + 0.015, _btnY, _btnW, 0.038];
_btnCancel ctrlSetText CFM_STR_CANCEL;
_btnCancel ctrlCommit 0;

private _btnOk = _display ctrlCreate ["RscButton", 103];
_btnOk ctrlSetPosition [_x + 0.025 + _btnW, _btnY, _btnW, 0.038];
_btnOk ctrlSetText CFM_STR_OK;
_btnOk ctrlCommit 0;

_display setVariable ["CFM_passEditCtrl", _edit];
_display setVariable ["CFM_passMonitor", _monitor];
_display setVariable ["CFM_passMode", _mode];
_display setVariable ["CFM_passCaller", _caller];
_display setVariable ["CFM_passTarget", _target];

private _onConfirm = {
	params ["_display"];
	if (isNull _display) exitWith {};
	private _editCtrl = _display getVariable ["CFM_passEditCtrl", controlNull];
	private _monitor = _display getVariable ["CFM_passMonitor", objNull];
	private _mode = _display getVariable ["CFM_passMode", "enter"];
	private _caller = _display getVariable ["CFM_passCaller", player];
	private _target = _display getVariable ["CFM_passTarget", _monitor];

	private _input = ctrlText _editCtrl;
	private _isLocal = _monitor getVariable ["CFM_isLocal", false];
	private _currentPass = _monitor getVariable ["CFM_password", ""];
	private _plrId = PLAYER_PASS_ID;

	switch (_mode) do {
		case "set": {
			_display closeDisplay 1;
			if (_input isEqualTo "") exitWith {};
			_monitor setVariable ["CFM_password", _input, !_isLocal];
			_monitor setVariable ["CFM_passwordAccess", [_plrId], !_isLocal];
			CFM_STR_PASSWORD_SET _HINT;
		};
		case "change": {
			_display closeDisplay 1;
			if (_input isEqualTo _currentPass) exitWith {};
			if (_input isEqualTo "") exitWith {
				_monitor setVariable ["CFM_password", "", !_isLocal];
				_monitor setVariable ["CFM_passwordAccess", [], !_isLocal];
				CFM_STR_PASSWORD_REMOVED _HINT;
			};
			_monitor setVariable ["CFM_password", _input, !_isLocal];
			_monitor setVariable ["CFM_passwordAccess", [_plrId], !_isLocal];
			CFM_STR_PASSWORD_CHANGED _HINT;
		};
		case "enter": {
			if (_input isEqualTo _currentPass) then {
				_display closeDisplay 1;
				private _accessList = +(_monitor getVariable ["CFM_passwordAccess", []]);
				_accessList pushBackUnique _plrId;
				_monitor setVariable ["CFM_passwordAccess", _accessList, !_isLocal];
				CFM_STR_PASSWORD_ACCEPTED _HINT;
				if !(_monitor getVariable ["CFM_feedActive", false]) then {
					["loadMenu", [_caller, _target]] CALL_OBJCLASS("Monitor", _monitor);
				};
			} else {
				_display closeDisplay 2;
				CFM_STR_WRONG_PASSWORD _HINT;
			};
		};
	};
};

_display setVariable ["CFM_passOnConfirm", _onConfirm];

_btnCancel ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"];
	(ctrlParent _ctrl) closeDisplay 2;
}];

_btnOk ctrlAddEventHandler ["ButtonClick", {
	params ["_ctrl"];
	private _disp = ctrlParent _ctrl;
	[_disp] call (_disp getVariable ["CFM_passOnConfirm", {}]);
}];

_display displayAddEventHandler ["KeyDown", {
	params ["_disp", "_key"];
	if (_key in [28, 156]) exitWith {
		[_disp] call (_disp getVariable ["CFM_passOnConfirm", {}]);
		true
	};
	false
}];

ctrlSetFocus _edit;
