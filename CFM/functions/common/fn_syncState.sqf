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

private _isWaiting = _monitor getVariable ["CFM_waitingForStart", false];

if (_isWaiting && _start) exitWith {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
};

_monitor setVariable ["CFM_waitingForStart", _start];

if (_start) then {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
	waitUntil {
		_start = _monitor getVariable ["CFM_waitingForStart", true];
		if !(_start) exitWith {true};
		if !(isPipEnabled) exitWith {false};
		if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {false};
		_operator = _monitor getVariable ["CFM_waitingForStartOperator", objNull];
		if !(IS_OBJ(_operator)) exitWith {
			_start = false;
			true
		};
		if !(_operator getVariable ["CFM_operatorSet", false]) exitWith {false};
		private _optimizeDistance = missionNamespace getVariable ["CFM_optimizeByDistance", OPTIMIZE_MONITOR_FEED_DIST];
		_optimizeDistance = call compile _optimizeDistance;
		if (_optimizeDistance <= 0) exitWith {true};
		private _dist = _monitor distance PLAYER_;
		private _isClose = _dist < _optimizeDistance;
		if (_isClose) exitWith {true};
		sleep 1;
		_isClose
	};
};
if (_start && {IS_OBJ(_operator)}) then {
	if (_monitor getVariable ["CFM_feedActive", false]) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	};
	[_monitor, _operator] call CFM_fnc_startOperatorFeed;
} else {
	if !(_monitor getVariable ["CFM_feedActive", true]) exitWith {};
	[_monitor] call CFM_fnc_stopOperatorFeed;
};
_monitor setVariable ["CFM_waitingForStart", false];
