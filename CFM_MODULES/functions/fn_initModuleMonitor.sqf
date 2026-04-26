#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	sleep 0.1;	

	private _syncedObjs = (synchronizedObjects _logic);

	private _mainObject = missionNamespace getVariable [(LGVAR ["monitorObject", ""]), objNull];

	if !(isNil "_mainObject") then {
		if (_mainObject isEqualType objNull) then {
			if !(_mainObject isEqualTo objNull) then {
				_syncedObjs pushBackUnique _mainObject;
			};
		};
	};
	
	private _monitors = _syncedObjs select {
		private _obj = _x;

		if (isNil "_obj") exitWith {false};
		if !(_obj isEqualType objNull) exitWith {false};
		if (isNull _obj) exitWith {false};

		true
	};

	if (_monitors isEqualTo []) exitWith {
		format["CFM_fnc_initModuleMonitor: ZERO MONITORS. Synced objects given: %1", _syncedObjs] DLOG
	};

	private _sidesStr = LGVAR ["monitorSides", ""];
	private _sides = (_sidesStr splitString " ,.;:[](){}") apply {
		private _compile = call compile _x;
		if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
			false
		} else {
			_compile
		};
	};
	_sides = _sides select {_x isEqualType west};

	if (_sides isEqualTo []) exitWith {
		format["CFM_fnc_initModuleMonitor: NO SIDES GIVEN. Side string: %1", _sidesStr] DLOG
	};

	[
		_monitors,
		_sides,
		BOOL("IsHandMonitorDisplay", 1),
		BOOL("monitorcanSwitchNvg", 1),
		BOOL("monitorCanSwitchTi", 1),
		BOOL("monitorCanSwitchTurret", 1),
		BOOL("monitorCanZoom", 1),
		BOOL("monitorCanFullScreen", 1),
		BOOL("monitorCanConnectDrone", 1)
	] call CFM_fnc_setMonitor;
};

