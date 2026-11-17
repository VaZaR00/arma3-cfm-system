/*
    Function: CFM_fnc_operatorCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_op", objNull], ["_monArg", objNull], ["_checkFeeding", false]];

private _monitor = objNull;
private _instId = -1;
if (_monArg isEqualType []) then {
	_monArg params [["_mObj", objNull], ["_mId", -1]];
	_monitor = _mObj;
	_instId = _mId;
} else {
	_monitor = _monArg;
};
if !(IS_OBJ(_monitor)) exitWith {false};
if (_instId < 1) then {
	_instId = [_monitor] call CFM_fnc_getSelectedMonitorInstance;
	if (_instId < 1) then {
		_instId = ((keys (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap])) param [0, -1]);
	};
};
if !(IS_VALID_OP(_op)) exitWith {
	["removeOperator", [_op]] CALL_CLASS("DbHandler");
	false
};

// REB COMPAT
if ((_op getVariable ["REB_uavLostSignal", false]) isEqualTo true) exitWith {false};
if (!(isNil "REB_fnc_isInDeadzone") && {
	!(isNil "REB_all_rebs") &&
	{
		((_op getVariable ["CFM_isDroneFeed", false]) isEqualTo true) && 
		{(_op call REB_fnc_isInDeadzone) isEqualTo true}
	}
}) exitWith {false};

private _hasActiveTurretsObjects = _op getVariable ["CFM_hasActiveTurretsObjects", -1];
if (_hasActiveTurretsObjects isEqualTo 0) exitWith {false};

// TURRETS / CAMERA OBJECT DESTROYED
if (call {
	// 1. Check if all cameras on operator are destroyed
	if ([_op, -2] call CFM_fnc_isOperatorCameraDestroyed) exitWith {true};

	// 2. Check if operator has no working turrets left
	private _allTurrs = _op getVariable ["CFM_allTurrets", []];
	private _activeTurrs = _op getVariable ["CFM_turrets", []];
	if ((_allTurrs isNotEqualTo []) && {_activeTurrs isEqualTo []}) exitWith {true};

	// 3. If monitor instance is connected, check current turret
	private _connectedOp = if (_instId > 0) then {
		MON_GVAR(_monitor, _instId, "CFM_connectedOperator", objNull)
	} else {objNull};
	if (_connectedOp isEqualTo _op) then {
		private _currTurret = TURRET_INDEX(MON_GVAR(_monitor, _instId, "CFM_currentTurret", DRIVER_TURRET_PATH));
		private _disabledTurrets = _op getVariable ["CFM_disabledTurrets", []];
		if (_currTurret in _disabledTurrets || {[_op, _currTurret] call CFM_fnc_isOperatorCameraDestroyed}) then {
			// Trigger turret checkup to disable dead turret and switch monitor to active turret
			_op call CFM_fnc_checkOperatorTurrets;
			(_op getVariable ["CFM_turrets", []]) isEqualTo []
		} else {
			false
		};
	} else {
		false
	};
}) exitWith {false};

private _cls = _op call CFM_fnc_getOperatorClass;
private _type = [_op] call CFM_fnc_cameraType;
if !(call {
	private _monitorAllowedOperator = if (_instId > 0) then {MON_GVAR(_monitor, _instId, "CFM_allowedOperators", [])} else {[]};
	private _monitorAllowedOperatorTypes = if (_instId > 0) then {MON_GVAR(_monitor, _instId, "CFM_allowedOperatorsTypes", [])} else {[]};
	if (IS_ARRAY(_monitorAllowedOperator) || {IS_ARRAY(_monitorAllowedOperatorTypes)}) exitWith {
		if (_op in _monitorAllowedOperator) exitWith {true};
		if (_cls in _monitorAllowedOperatorTypes) exitWith {true};
		if (_type in _monitorAllowedOperatorTypes) exitWith {true};
		false
	};
	private _monitorSides = if (_instId > 0) then {MON_GVAR(_monitor, _instId, "CFM_monitorSides", [])} else {[]};
	private _sidesOp = _op getVariable ["CFM_opSides", [[(getNumber (configFile >> "CfgVehicles" >> _cls >> "side"))] call BIS_fnc_sideType]];
	private _sidesUseCiv = missionNamespace getVariable ["CFM_sidesCanUseCiv", []];
	if !(_sidesOp isEqualType []) then {
		_sidesOp = [_sidesOp];
	};
	if !(_monitorSides isEqualType []) then {
		_monitorSides = [_monitorSides];
	};
	private _bySide = (_monitorSides findIf {_x in _sidesOp}) != -1;
	private _bySideCiv = (_monitorSides findIf {_x in _sidesUseCiv}) != -1;
	if (!_bySide && {!(_bySideCiv && {civilian in _sidesOp})}) exitWith {false};
	true
}) exitWith {false};

if (_checkFeeding && {!(_op getVariable ["CFM_isFeeding", false])}) exitWith {false};

switch (_type) do {
	case GOPRO: {
		if (!(MGVAR ["CFM_goProCanFeedIfDead", true]) && {!(alive _op)}) exitWith {false};
		private _hasGoPro = _op getVariable ["CFM_hasGoPro", false];
		private _goprohelms = missionNamespace getVariable "CFM_goProHelmets";
		if (isNil "_goprohelms") exitWith {_hasGoPro};
		private _playerHelm = headgear _op;
		_playerHelm in _goprohelms;
	};
	case TYPE_STATIC: {
		true
	};
	default {
		if !(alive _op) exitWith {false};
		private _canFeed = _op getVariable ["CFM_canFeed", false];
		if (_canFeed) exitWith {true};
		private _isnew = [_op] call CFM_fnc_checkIfNewOperator;
		if (isNil "_isnew") exitWith {false};
		_isnew isEqualTo true
	};
};
