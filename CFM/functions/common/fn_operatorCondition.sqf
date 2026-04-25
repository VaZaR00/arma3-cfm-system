/*
    Function: CFM_fnc_operatorCondition
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_op", ["_monitor", objNull], ["_checkFeeding", false]];

if !(IS_OBJ(_monitor)) exitWith {false};

private _hasActiveTurretsObjects = _op getVariable ["CFM_hasActiveTurretsObjects", -1];
if (_hasActiveTurretsObjects isEqualTo 0) exitWith {false};

if !(IS_VALID_OP(_op)) then {
	["removeOperator", [_op]] CALL_CLASS("DbHandler");
	continue
};
private _cls = _op call CFM_fnc_getOperatorClass;
private _monitorSides = _monitor getVariable ["CFM_monitorSides", [side _monitor]];
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

if (_checkFeeding && {!(_op getVariable ["CFM_isFeeding", false])}) exitWith {false};

private _type = [_op] call CFM_fnc_cameraType;

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
