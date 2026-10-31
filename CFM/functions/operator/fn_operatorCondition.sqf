/*
    Function: CFM_fnc_operatorCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_op", objNull], ["_monitor", objNull], ["_checkFeeding", false]];

if !(IS_OBJ(_monitor)) exitWith {false};
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

// CAMERA OBJECT (proxy) DESTROYED
if (call {
	if ((_op getVariable ["CFM_cameraObjects", createHashMap]) isEqualTo createHashMap) exitWith {false};
	private _checkTurret = if ((_monitor getVariable ["CFM_connectedOperator", objNull]) isEqualTo _op) then {
		TURRET_INDEX(_monitor getVariable ["CFM_currentTurret" I DRIVER_TURRET_PATH])
	} else {
		if (_monitor getVariable ["CFM_isVehTablet", false]) then {
			private _foundTurret = -2;
			private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
			{
				private _seatInstId = _y;
				private _seatOp = OIVAR(_monitor, "SeatTablet", _connectedOperator, _seatInstId, objNull);
				if (_seatOp isEqualTo _op) exitWith {
					private _turr = OIVAR(_monitor, "SeatTablet", _currentTurret, _seatInstId, DRIVER_TURRET_PATH);
					_foundTurret = TURRET_INDEX(_turr);
				};
			} forEach _seatInstances;
			_foundTurret
		} else {-2};
	};
	[_op, _checkTurret] call CFM_fnc_isOperatorCameraDestroyed
}) exitWith {false};

private _cls = _op call CFM_fnc_getOperatorClass;
private _type = [_op] call CFM_fnc_cameraType;
if !(call {
	private _monitorAllowedOperator = _monitor getVariable ["CFM_allowedOperators", []];
	private _monitorAllowedOperatorTypes = _monitor getVariable ["CFM_allowedOperatorsTypes", []];
	if (IS_ARRAY(_monitorAllowedOperator) || {IS_ARRAY(_monitorAllowedOperatorTypes)}) exitWith {
		if (_op in _monitorAllowedOperator) exitWith {true};
		if (_cls in _monitorAllowedOperatorTypes) exitWith {true};
		if (_type in _monitorAllowedOperatorTypes) exitWith {true};
		false
	};
	private _monitorSides = _monitor getVariable ["CFM_monitorSides", []];
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
