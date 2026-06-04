/*
    Function: CFM_fnc_syncState
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_mNetId", "_oNetId", ["_start", true], ["_turret", DRIVER_TURRET_PATH]];

private _monitor = if (_mNetId isEqualType "") then {objectFromNetId _mNetId} else {_mNetId};
private _operator = if (_oNetId isEqualType "") then {objectFromNetId _oNetId} else {_oNetId};

if !(IS_OBJ(_monitor)) exitWith {};
if (_start && {!(IS_OBJ(_operator))}) exitWith {};

if (isServer) then {
	if (_start) then {
		["CFM_operatorMonitorConnected", [_operator, _monitor], _operator] call CBA_fnc_targetEvent;
	} else {
		_operator = _monitor getVariable ["CFM_connectedOperator", objNull];
		["CFM_operatorMonitorDisconnected", [_operator, _monitor], _operator] call CBA_fnc_targetEvent;
	};
};

private _isWaiting = _monitor getVariable ["CFM_waitingForStart", false];

if (_isWaiting && _start) exitWith {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
};

_monitor setVariable ["CFM_waitingForStart", _start];

if (_start && {hasInterface}) then {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
	waitUntil {
		private _cond = call {
			_start = _monitor getVariable ["CFM_waitingForStart", true];
			if !(_start) exitWith {true};
			if !(isPipEnabled) exitWith {false};
			if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {false};
			_operator = _monitor getVariable ["CFM_waitingForStartOperator", objNull];
			if !(IS_OBJ(_operator)) exitWith {
				_start = false;
				true
			};
			_turret = _monitor getVariable ["CFM_waitingForStartTurret", DRIVER_TURRET_PATH];
			if !(_operator getVariable ["CFM_operatorSet", false]) exitWith {false};
			private _optimizeDistance = GET_OPTIMIZE_DIST;
			if (_optimizeDistance <= 0) exitWith {true};
			private _dist = _monitor distance PLAYER_;
			private _isClose = _dist < _optimizeDistance;
			if (_isClose) exitWith {true};
			_isClose
		};
		if (_cond) exitWith {true};
		sleep 1;
		_cond
	};
};
if (_start && {IS_OBJ(_operator)}) then {
	if (_monitor getVariable ["CFM_feedActive", false]) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	};
	[_monitor, _operator, _turret] call CFM_fnc_startOperatorFeed;
} else {
	if !(_monitor getVariable ["CFM_feedActive", true]) exitWith {};
	[_monitor] call CFM_fnc_stopOperatorFeed;
};
_monitor setVariable ["CFM_waitingForStart", false];
