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

CFM_fnc_getCrewSeatKey = {
	params ["_crewEntry"];
	_crewEntry params ["", ["_role", ""], ["_cargoIdx", -1], ["_turretPath", []]];
	_role = toLower _role;
	if (_role isEqualTo "driver") exitWith {"driver"};
	if !(_turretPath isEqualTo []) exitWith {format ["turret_%1", _turretPath]};
	format ["cargo_%1", _cargoIdx]
};

CFM_fnc_getUnitVehicleSeatKey = {
	params [["_veh", objNull], ["_unit", PLAYER_]];
	if !(IS_OBJ(_veh)) exitWith {""};
	if !(_unit in _veh) exitWith {""};
	private _crew = (fullCrew [_veh, "", false]) select {(_x select 0) isEqualTo _unit};
	if (_crew isEqualTo []) exitWith {""};
	[_crew select 0] call CFM_fnc_getCrewSeatKey
};

CFM_fnc_isCrewSeatAllowed = {
	params ["_veh", "_crewEntry"];
	private _vehMonSeats = _veh getVariable ["CFM_vehicleTabletSeats", []];
	if (_vehMonSeats isEqualTo []) exitWith {true};
	_crewEntry params [["_unit", objNull], ["_role", ""], ["_cargoIdx", -1], ["_turretPath", []]];
	_role = toLower _role;
	if (IS_OBJ(_unit) && {(_unit in _veh) && {(assignedVehicleRole _unit) in _vehMonSeats}}) exitWith {true};
	([_role] in _vehMonSeats) ||
	{([_role, _turretPath] in _vehMonSeats)} ||
	{([_role, _cargoIdx] in _vehMonSeats)} ||
	{(!(_turretPath isEqualTo []) && {(["turret", _turretPath] in _vehMonSeats)})} ||
	{((_role isEqualTo "driver") && {(["turret", [-1]] in _vehMonSeats)})}
};

CFM_fnc_getOrCreateSeatTabletId = {
	params [["_monitor", objNull], ["_seatKey", ""]];
	if (!(IS_OBJ(_monitor)) || {_seatKey isEqualTo ""}) exitWith {-1};
	private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
	private _instId = _seatInstances getOrDefault [_seatKey, -1];
	if (_instId > 0) exitWith {_instId};
	["setSeatTablet", [_seatKey], -1] CALL_OBJCLASS("Monitor", _monitor)
};

CFM_fnc_isVehTabletUsingOperator = {
	params ["_monitor", "_operator", ["_turretIdx", nil]];
	if !(_monitor getVariable ["CFM_isVehTablet", false]) exitWith {false};
	private _seatInstances = _monitor getVariable ["CFM_seatTabletsInstances", createHashMap];
	private _used = false;
	{
		private _seatInstId = _y;
		private _op = OIVAR(_monitor, "SeatTablet", _connectedOperator, _seatInstId, objNull);
		if (_op isEqualTo _operator) then {
			if (isNil "_turretIdx") exitWith { _used = true; };
			private _turr = OIVAR(_monitor, "SeatTablet", _currentTurret, _seatInstId, DRIVER_TURRET_PATH);
			if (TURRET_INDEX(_turr) isEqualTo TURRET_INDEX(_turretIdx)) exitWith { _used = true; };
		};
		if (_used) exitWith {};
	} forEach _seatInstances;
	_used
};

CFM_fnc_inVehicleTabletSeatCondition = {
	params ["_target"];
	if !(_target getVariable ["CFM_isVehTablet", false]) exitWith {true};
	private _plr = PLAYER_;
	if !(_plr in _target) exitWith {false};
	private _roleInfo = (fullCrew [_target, "", false]) select {(_x select 0) isEqualTo _plr};
	if (_roleInfo isEqualTo []) exitWith {false};
	[_target, _roleInfo select 0] call CFM_fnc_isCrewSeatAllowed
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
