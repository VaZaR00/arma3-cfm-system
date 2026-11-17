/*
    Function: CFM_fnc_monitorCloseMenu
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monArg", objNull], ["_actionObj", objNull]];

if !(_actionObj isEqualType objNull) then {
	_actionObj = objNull;
};

if (_monArg isEqualType []) then {
	_monArg params [["_monObj", objNull], ["_instId", -1]];
	if !(IS_OBJ(_monObj)) exitWith {};
	if (isNull _actionObj) then {_actionObj = _monObj};
	{ _actionObj removeAction _x } forEach (_actionObj getVariable ["CFM_tempActions", []]);
	_actionObj setVariable ["CFM_tempActions", []];
	if (_instId > 0) then {
		private _curMenuObj = MON_GVAR(_monObj, _instId, "CFM_currentMenuObj", objNull);
		if (!isNull _curMenuObj && {!(_curMenuObj isEqualTo _actionObj)}) then {
			{ _curMenuObj removeAction _x } forEach (_curMenuObj getVariable ["CFM_tempActions", []]);
			_curMenuObj setVariable ["CFM_tempActions", []];
		};
		MON_SVAR(_monObj, _instId, "CFM_menuActive", false);
	};
	private _activeInst = _monObj getVariable ["CFM_activeMenuInstance", -1];
	if (_activeInst > 0) then {
		MON_SVAR(_monObj, _activeInst, "CFM_menuActive", false);
		_monObj setVariable ["CFM_activeMenuInstance", -1];
	};
	_monObj setVariable ["CFM_menuActive", false];
} else {
	private _monitor = _monArg;
	if !(IS_OBJ(_monitor)) exitWith {};
	if (isNull _actionObj) then {_actionObj = _monitor};
	{ _actionObj removeAction _x } forEach (_actionObj getVariable ["CFM_tempActions", []]);
	_actionObj setVariable ["CFM_tempActions", []];
	private _activeInst = _monitor getVariable ["CFM_activeMenuInstance", -1];
	if (_activeInst > 0) then {
		private _curMenuObj = MON_GVAR(_monitor, _activeInst, "CFM_currentMenuObj", objNull);
		if (!isNull _curMenuObj && {!(_curMenuObj isEqualTo _actionObj)}) then {
			{ _curMenuObj removeAction _x } forEach (_curMenuObj getVariable ["CFM_tempActions", []]);
			_curMenuObj setVariable ["CFM_tempActions", []];
		};
		MON_SVAR(_monitor, _activeInst, "CFM_menuActive", false);
		_monitor setVariable ["CFM_activeMenuInstance", -1];
	};
	_monitor setVariable ["CFM_menuActive", false];
};