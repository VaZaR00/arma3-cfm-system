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

CFM_fnc_inVehicleTabletSeatCondition = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	private _plr = PLAYER_;
	if !(_plr in _target) exitWith {false};
	private _vehMonSeats = _target getVariable ["CFM_vehicleTabletSeats", []];
	if (_vehMonSeats isEqualTo []) exitWith {true};
	if ((assignedVehicleRole _plr) in _vehMonSeats) exitWith {true};
	private _roleInfo = (fullCrew [_target, "", false]) select {(_x select 0) isEqualTo _plr};
	if (_roleInfo isEqualTo []) exitWith {false};
	(_roleInfo select 0) params ["", "_role", "", "_turretPath"];
	_role = toLower _role;
	([_role] in _vehMonSeats) || {([_role, _turretPath] in _vehMonSeats)} || {(["turret", _turretPath] in _vehMonSeats)}
};

CFM_fnc_inVehicleTabletActionCondition = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	private _plr = PLAYER_;
	if (_plr getVariable ["CFM_menuActive", false]) exitWith {false};
	[_target] call CFM_fnc_inVehicleTabletSeatCondition
};

CFM_fnc_hasMonitorPasswordAccess = {
	params ["_monitor"];
	if !(_monitor getVariable ["CFM_canSetPassword", false]) exitWith {true};
	private _pass = _monitor getVariable ["CFM_password", ""];
	if (_pass isEqualTo "") exitWith {true};
	if ((MGVAR ["CFM_debug", false]) || {PLAYER_IS_ADMIN && {(MGVAR ["CFM_adminHaveAccessToAllMonitors", false])}}) exitWith {true};
	private _accessList = _monitor getVariable ["CFM_passwordAccess", []];
	PLAYER_PASS_ID in _accessList
};

// EFL WRAPPERS
#define EFL_WRAP(f) FUNC(f) = {(IF_NIL(_this, [])) call TRIPLE(EFL_PREF,_fnc_,f)};

EFL_WRAP(pushBackGlobal);
EFL_WRAP(hashSetGlobal);
EFL_WRAP(removeFromArrayGlobal);
EFL_WRAP(deleteAtGlobal);
EFL_WRAP(publicVariableServer);
EFL_WRAP(pushBackNet);
EFL_WRAP(pushBack);
EFL_WRAP(hashSetNet);
EFL_WRAP(hashSet);
EFL_WRAP(removeFromArrayNet);
EFL_WRAP(removeFromArray);
EFL_WRAP(deleteAtNet);
EFL_WRAP(deleteAt);
EFL_WRAP(remoteExec);
EFL_WRAP(remoteEvent);
EFL_WRAP(callVariableEH);
EFL_WRAP(publicVariable);
EFL_WRAP(setVariable);
