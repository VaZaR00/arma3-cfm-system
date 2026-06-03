#include "defines.hpp" 

CFM_fnc_checkTurretsLocality = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _turrets = if (_turretPath isEqualTo []) then {
		allTurrets _operator
	} else {
		[_turretPath]
	};
	private _hasLocalTurret = false;
	{
		_hasLocalTurret = _operator turretLocal _x;
		if (_hasLocalTurret) exitWith {break};
	} forEach _turrets;
	_hasLocalTurret
};
#define LOCAL_ACTIVE_OPERATORS_VAR CFM_LocalActiveOperators
#define LOCAL_ACTIVE_OPERATORS_VAR_STR STR(LOCAL_ACTIVE_OPERATORS_VAR)
CFM_fnc_addLocalTurretOperator = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _localOps = (missionNamespace getVariable [LOCAL_ACTIVE_OPERATORS_VAR_STR, []]);
	private _operatorInLocalOps = (_localOps findIf {(_x select 0) isEqualTo _operator});
	if (_operatorInLocalOps < 0) then {
		_localOps pushBack [_operator, [_turretPath]];
	} else {
		private _turrets = (_localOps param [_operatorInLocalOps, [objNull, []]]) param [1, []];
		_turrets pushBackUnique _turretPath;
		_localOps set [_operatorInLocalOps, [_operator, _turrets]];
	};
	LOCAL_ACTIVE_OPERATORS_VAR = _localOps;
	LOCAL_ACTIVE_OPERATORS_VAR
};
CFM_fnc_removeLocalTurretOperator = {
	params [["_operator", objNull], ["_turretPath", []]];
	
	private _localOps = (missionNamespace getVariable [LOCAL_ACTIVE_OPERATORS_VAR_STR, []]);
	private _operatorInLocalOps = (_localOps findIf {(_x select 0) isEqualTo _operator});
	if (_operatorInLocalOps < 0) exitWith {_localOps}; // operator not found, nothing to remove

	private _turrets = (_localOps param [_operatorInLocalOps, [objNull, []]]) param [1, []];
	_turrets = _turrets - [_turretPath];
	
	if (_turrets isEqualTo []) then {
		_localOps deleteAt _operatorInLocalOps;
	} else {
		_localOps set [_operatorInLocalOps, [_operator, _turrets]];
	};
	LOCAL_ACTIVE_OPERATORS_VAR = _localOps;
	LOCAL_ACTIVE_OPERATORS_VAR
};
CFM_fnc_setupDefPointAlignments = {
	private _pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
	if (_pointSetDef isEqualTo createHashMap) then {
		[] call CFM_fnc_initDefaultPointsAlignment;
		_pointSetDef = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	} else {
		missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSetDef];
	};
	CFM_initDefPointAlignmentsSet = true;
	_pointSetDef
};

CFM_fnc_inVehicleTabletActionCondition = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	private _plr = PLAYER_;
	if !(_plr in _target) exitWith {false};
	private _vehMonSeats = _target getVariable ["CFM_vehicleTabletSeats", []];
	if (_vehMonSeats isEqualTo []) exitWith {true};
	(assignedVehicleRole _plr) in _vehMonSeats
};