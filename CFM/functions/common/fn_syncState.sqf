/*
    Function: CFM_fnc_syncState
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 


params ["_mNetId", "_oNetId", ["_start", true], ["_turret", nil], ["_isOptimize", false], ["_instIdArg", -1]];

private _monitor = objNull;
private _instId = _instIdArg;
if (_mNetId isEqualType []) then {
	_mNetId params [["_mTarget", objNull], ["_mId", -1]];
	_monitor = if (_mTarget isEqualType "") then {objectFromNetId _mTarget} else {_mTarget};
	if (_instId < 1) then {_instId = _mId};
} else {
	_monitor = if (_mNetId isEqualType "") then {objectFromNetId _mNetId} else {_mNetId};
	if (_instId < 1 && {IS_OBJ(_monitor)}) then {
		_instId = [_monitor] call CFM_fnc_getSelectedMonitorInstance;
		if (_instId < 1) then {
			_instId = ((keys (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap])) param [0, -1]);
		};
	};
};
private _operator = if (_oNetId isEqualType "") then {objectFromNetId _oNetId} else {_oNetId};

if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {};
if (_start && {!(IS_OBJ(_operator))}) exitWith {};
private _monPair = [_monitor, _instId];

if (isServer && !_isOptimize) then {
	private _monIsLocal = MON_GVAR(_monitor, _instId, "CFM_isLocal", false);
	if (_start) then {
		private _initTurr = MON_GVAR(_monitor, _instId, "CFM_waitingForStartTurret", if (isNil "_turret") then {DRIVER_TURRET_PATH} else {_turret});
		MON_SVARG(_monitor, _instId, "CFM_connectedOperator", _operator, !_monIsLocal);
		MON_SVARG(_monitor, _instId, "CFM_waitingForStartTurret", _initTurr, !_monIsLocal);
		["CFM_operatorMonitorConnected", [_operator, _monPair, _initTurr], _operator] call CBA_fnc_targetEvent;
	} else {
		_operator = MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull);
		MON_SVARG(_monitor, _instId, "CFM_connectedOperator", nil, !_monIsLocal);
		MON_SVARG(_monitor, _instId, "CFM_waitingForStartTurret", nil, !_monIsLocal);
		["CFM_operatorMonitorDisconnected", [_operator, _monPair], _operator] call CBA_fnc_targetEvent;
	};
};

private _waitVar = MON_VAR_NAME("CFM_waitingForStart", _instId);
private _isWaiting = _monitor getVariable [_waitVar, false];

if (_isWaiting && _start) exitWith {
	MON_SVAR(_monitor, _instId, "CFM_waitingForStartOperator", _operator);
	if !(isNil "_turret") then {
		MON_SVAR(_monitor, _instId, "CFM_waitingForStartTurret", _turret);
	};
};

_monitor setVariable [_waitVar, _start];
private _localSkipOnly = false;

if (_start && {hasInterface}) then {
	MON_SVAR(_monitor, _instId, "CFM_waitingForStartOperator", _operator);
	if (!isNil "_turret" && {!(MON_GVAR(_monitor, _instId, "CFM_seatKey", "") isEqualTo "") || {isNil {_monitor getVariable (MON_VAR_NAME("CFM_waitingForStartTurret", _instId))}}}) then {
		MON_SVAR(_monitor, _instId, "CFM_waitingForStartTurret", _turret);
	};
	waitUntil {
		private _cond = call {
			_start = _monitor getVariable [_waitVar, true];
			if !(_start) exitWith {true};
			if !(isPipEnabled) exitWith {false};
			if !(_monitor getVariable ["CFM_isMonitorSet", false]) exitWith {false};
			if !(MON_GVAR(_monitor, _instId, "CFM_isMonitorInstanceSet", false)) exitWith {false};

			private _isVehSeatTablet = MON_GVAR(_monitor, _instId, "CFM_isVehSeatTablet", false);
			private _seatKey = MON_GVAR(_monitor, _instId, "CFM_seatKey", "");
			private _texSel = MON_GVAR(_monitor, _instId, "CFM_textureSelection", NO_TEXTURE_SELECTION);
			private _inReqSeat = !_isVehSeatTablet || {_seatKey isEqualTo ""} || {
				(PLAYER_ in _monitor) && {(([_monitor, PLAYER_] call CFM_fnc_getUnitVehicleSeatKey) isEqualTo _seatKey)}
			};
			private _needSeatForRender = (_texSel < 0) || {!(missionNamespace getVariable ["CFM_renderSeatTextureOutOfSeat", true])};
			if (_isVehSeatTablet && {_needSeatForRender} && {!_inReqSeat}) exitWith {
				_start = false;
				_localSkipOnly = true;
				true
			};

			_operator = MON_GVAR(_monitor, _instId, "CFM_waitingForStartOperator", objNull);
			if !(IS_OBJ(_operator)) exitWith {
				_start = false;
				true
			};
			_turret = MON_GVAR(_monitor, _instId, "CFM_waitingForStartTurret", MON_GVAR(_monitor, _instId, "CFM_currentTurret", DRIVER_TURRET_PATH));
			if !(_operator getVariable ["CFM_operatorSet", false]) exitWith {false};
			if (_isVehSeatTablet && {_inReqSeat}) exitWith {true};
			if (MON_GVAR(_monitor, _instId, "CFM_isHandMonitor", false)) exitWith {true};

			private _optimizeDistance = GET_OPTIMIZE_DIST;
			if (_optimizeDistance <= 0) exitWith {true};
			(_monitor distance PLAYER_) < _optimizeDistance
		};
		if (_cond) exitWith {true};
		sleep 1;
		_cond
	};
};
if (_start && {IS_OBJ(_operator)}) then {
	if (MON_GVAR(_monitor, _instId, "CFM_feedActive", false)) then {
		[_monPair, false, _isOptimize] call CFM_fnc_stopOperatorFeed;
	};
	_turret = MON_GVAR(_monitor, _instId, "CFM_waitingForStartTurret", MON_GVAR(_monitor, _instId, "CFM_currentTurret", if (isNil "_turret") then {DRIVER_TURRET_PATH} else {_turret}));
	[_monPair, _operator, _turret, _isOptimize] call CFM_fnc_startOperatorFeed;
} else {
	private _feedActive = MON_GVAR(_monitor, _instId, "CFM_feedActive", false);
	if (_localSkipOnly) then {
		if (_feedActive) then {
			[_monPair, false, true] call CFM_fnc_stopOperatorFeed;
		};
	} else {
		if (_feedActive) then {
			[_monPair, false, _isOptimize] call CFM_fnc_stopOperatorFeed;
		} else {
			["clearVariables"] CALL_MON_INST(_monitor, _instId);
		};
	};
};
_monitor setVariable [_waitVar, false];
