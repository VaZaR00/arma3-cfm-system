/*
    Function: CFM_fnc_remoteExec
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", true], ["_call", false, [false]]];

if (_func isEqualType {}) then {
	_args = [_args, _func];
	_func = if (_call) then {"call"} else {"call"};
};
if !(_func isEqualType "") exitWith {format["CFM_fnc_remoteExec ERROR: func not str or code. Func type: %1. Func value: %2", typeName _func, _func] WARN};

if (_targets isEqualType true) then {
	if (_targets isEqualTo true) then {
		_targets = 0;
	} else {
		_targets = false;
	};
};
if (_jip isEqualType objNull) then {
	private _netid = netId _jip;
	private _idArr = (_netid splitString ":");
	private _id = "0";
	if (count _idArr > 1) then {
		_id = trim (_idArr#1);
		if !(_id isEqualType "") then {
			_id = str _id;
		};
	};
	_jip = "CFM_jip_remote_exec_id_" + _id;
};

if (!isMultiplayer || {(_targets in [PLAYER_, false, clientOwner])}) exitWith {
	if (_func isEqualTo "call") exitWith {
		(_args#0) call (_args#1)
	};
	if (_func isEqualTo "spawn") exitWith {
		(_args#0) spawn (_args#1)
	};
	private _func = missionNamespace getVariable [_func, {format["CFM_fnc_remoteExec ERROR: func '%1' not found!", _func] WARN}];
	if (_call) then {
		_args call _func
	} else {
		_args spawn _func
	};
};
if (_call isEqualTo true) then {
	_args remoteExecCall [_func, _targets, _jip];
} else {
	_args remoteExec [_func, _targets, _jip];
};
