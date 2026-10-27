/*
    Function: CFM_fnc_syncState
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_mNetId", "_oNetId", ["_start", true], ["_turret", nil], ["_isOptimize", false], ["_seatKey", ""]];

private _monitor = if (_mNetId isEqualType "") then {objectFromNetId _mNetId} else {_mNetId};
private _operator = if (_oNetId isEqualType "") then {objectFromNetId _oNetId} else {_oNetId};

if !(IS_OBJ(_monitor)) exitWith {};
if (_start && {!(IS_OBJ(_operator))}) exitWith {};

if (isServer && !_isOptimize) then {
	private _monIsLocal = _monitor getVariable ["CFM_isLocal", false];
	if (_start) then {
		private _initTurr = _monitor getVariable ["CFM_waitingForStartTurret", if (isNil "_turret") then {DRIVER_TURRET_PATH} else {_turret}];
		_monitor setVariable ["CFM_connectedOperator", _operator, !_monIsLocal];
		_monitor setVariable ["CFM_waitingForStartTurret", _initTurr, !_monIsLocal];
		["CFM_operatorMonitorConnected", [_operator, _monitor, _initTurr], _operator] call CBA_fnc_targetEvent;
	} else {
		_operator = _monitor getVariable ["CFM_connectedOperator", objNull];
		_monitor setVariable ["CFM_connectedOperator", nil, !_monIsLocal];
		_monitor setVariable ["CFM_waitingForStartTurret", nil, !_monIsLocal];
		["CFM_operatorMonitorDisconnected", [_operator, _monitor], _operator] call CBA_fnc_targetEvent;
	};
};

private _isWaiting = _monitor getVariable ["CFM_waitingForStart" + _seatKey, false];

if (_isWaiting && _start) exitWith {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
	if !(isNil "_turret") then {
		_monitor setVariable ["CFM_waitingForStartTurret", _turret];
	};
};

_monitor setVariable ["CFM_waitingForStart" + _seatKey, _start];

if (_start && {hasInterface}) then {
	_monitor setVariable ["CFM_waitingForStartOperator", _operator];
	if (!isNil "_turret" && {isNil {_monitor getVariable "CFM_waitingForStartTurret"}}) then {
		_monitor setVariable ["CFM_waitingForStartTurret", _turret];
	};
	waitUntil {
		private _cond = call {
			_start = _monitor getVariable ["CFM_waitingForStart" + _seatKey, true];
			if !(_start) exitWith {true};
			if !(isPipEnabled) exitWith {false};
			if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {false};
			_operator = _monitor getVariable ["CFM_waitingForStartOperator", objNull];
			if !(IS_OBJ(_operator)) exitWith {
				_start = false;
				true
			};
			_turret = _monitor getVariable ["CFM_waitingForStartTurret", _monitor getVariable ["CFM_currentTurret", DRIVER_TURRET_PATH]];
			if !(_operator getVariable ["CFM_operatorSet", false]) exitWith {false};
			if (_monitor getVariable ["CFM_isVehTablet", false]) exitWith {
				([_monitor, PLAYER_] call CFM_fnc_getUnitVehicleSeatKey) isEqualTo _seatKey
			};
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
	_turret = _monitor getVariable ["CFM_waitingForStartTurret", _monitor getVariable ["CFM_currentTurret", if (isNil "_turret") then {DRIVER_TURRET_PATH} else {_turret}]];
	[_monitor, _operator, _turret, _isOptimize] call CFM_fnc_startOperatorFeed;
} else {
	if (_monitor getVariable ["CFM_feedActive", false]) then {
		[_monitor] call CFM_fnc_stopOperatorFeed;
	} else {
		["clearVariables"] CALL_OBJCLASS("Monitor", _monitor);
	};
};
_monitor setVariable ["CFM_waitingForStart" + _seatKey, false];
