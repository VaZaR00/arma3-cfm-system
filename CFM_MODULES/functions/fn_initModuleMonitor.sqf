#include "defines.hpp"

#define LGVAR _logic GV 
#undef BOOL
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define SELECT_DEF(var, def) (call {private _val = (LGVAR [var, def]); if (_val isEqualTo -1) then {-1} else {_val isEqualTo 1}})

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic, _units] spawn {
	params ["_logic", ["_units", []]];

	sleep 0.1;	

	if (_logic getVariable ["CFM_monInitExecuted", false]) exitWith {};
	_logic setVariable ["CFM_monInitExecuted", true];

	private _fnc_getTarget = {
		params ["_l"];
		private _tgt = _l getVariable ["bis_fnc_curatorAttachObject_object", objNull];
		if (!isNull _tgt) exitWith {_tgt};
		_tgt = attachedTo _l;
		if (!isNull _tgt) exitWith {_tgt};
		private _att = attachedObjects _l;
		if (_att isNotEqualTo []) exitWith {_att select 0};
		objNull
	};

	private _syncedObjs = (synchronizedObjects _logic);
	private _target = [_logic] call _fnc_getTarget;
	if (IS_OBJ(_target) && {!(_target isKindOf "Logic")}) then {
		_syncedObjs pushBackUnique _target;
	};
	{
		if (IS_OBJ(_x) && {!(_x isKindOf "Logic")}) then {
			_syncedObjs pushBackUnique _x;
		};
	} forEach _units;

	private _monitorsStr = LGVAR ["monitorObject", ""];
	{
		private _monObj = missionNamespace getVariable [_x, objNull];
		if (IS_OBJ(_monObj)) then {
			_syncedObjs pushBackUnique _monObj;
		};
	} forEach (_monitorsStr splitString SPLIT_CHARACTERS);
	
	private _monitors = _syncedObjs select {
		private _obj = _x;

		if (isNil "_obj") exitWith {false};
		if !(_obj isEqualType objNull) exitWith {false};
		if (isNull _obj) exitWith {false};
		if (_obj isKindOf "Logic") exitWith {false};

		true
	};

	if (_monitors isEqualTo []) exitWith {
		format["CFM_fnc_initModuleMonitor: ZERO MONITORS. Synced objects given: %1", _syncedObjs] WARN
	};

	private _sidesStr = LGVAR ["monitorSides", "west"];
	if (_sidesStr isEqualTo "") then { _sidesStr = "west"; };
	private _sides = (_sidesStr splitString SPLIT_CHARACTERS) apply {
		private _compile = call compile _x;
		if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
			false
		} else {
			_compile
		};
	};
	_sides = _sides select {_x isEqualType west};

	private _allowedOpsStr = LGVAR ["allowedOperators", ""];
	private _allowedOperators = [];
	{
		private _opObj = missionNamespace getVariable [_x, objNull];
		if (IS_OBJ(_opObj)) then {
			_allowedOperators pushBackUnique _opObj;
		};
	} forEach (_allowedOpsStr splitString (SPLIT_CHARACTERS + "[]"));

	private _allowedOpsTypesStr = LGVAR ["allowedOperatorsTypes", ""];
	private _allowedOperatorsTypes = (_allowedOpsTypesStr splitString (SPLIT_CHARACTERS + """'[]")) select {!(_x isEqualTo "")};

	if ((_sides isEqualTo []) && (_allowedOperators isEqualTo []) && (_allowedOperatorsTypes isEqualTo [])) then {
		_sides = [west];
	};

	private _vehSeatsStr = trim (LGVAR ["vehicleTabletSeats", ""]);
	private _vehicleTabletSeats = if (_vehSeatsStr isEqualTo "") then {
		-1
	} else {
		if ("[" in _vehSeatsStr) then {
			private _compiledSeats = call compile _vehSeatsStr;
			if (isNil "_compiledSeats" || {!(_compiledSeats isEqualType [])}) then {-1} else {_compiledSeats}
		} else {
			(_vehSeatsStr splitString SPLIT_CHARACTERS) apply {[toLower _x]}
		}
	};

	[
		_monitors,
		_sides,
		_allowedOperators,
		_allowedOperatorsTypes,
		BOOL("IsHandMonitorDisplay", 0),
		_vehicleTabletSeats,
		SELECT_DEF("isVehTablet", -1),
		BOOL("monitorcanSwitchNvg", 1),
		BOOL("monitorCanSwitchTi", 1),
		BOOL("monitorCanSwitchTurret", 1),
		BOOL("monitorCanZoom", 1),
		BOOL("monitorCanFullScreen", 1),
		BOOL("monitorCanConnectDrone", 1),
		BOOL("monitorCanFix", 1),
		BOOL("monitorCanTurnOffLocal", 1),
		BOOL("monitorHasPassword", 1),
		LGVAR ["ScreenResolution", ""]
	] call CFM_fnc_setMonitor;
};
