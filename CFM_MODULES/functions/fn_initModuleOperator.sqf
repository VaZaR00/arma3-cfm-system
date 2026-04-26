#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define SELECT_DEF(var, def) (call {private _val = (LGVAR [var, def]); if (_val isEqualTo -1) then {-1} else {_val isEqualTo 1}})

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	sleep 0.1;	

	private _syncedObjs = (synchronizedObjects _logic);

	private _mainObject = missionNamespace getVariable [(LGVAR ["operatorObject", ""]), objNull];

	if !(isNil "_mainObject") then {
		if (_mainObject isEqualType objNull) then {
			if !(_mainObject isEqualTo objNull) then {
				_syncedObjs = [_mainObject] + _syncedObjs;
			};
		};
	};
	
	private _operators = _syncedObjs select {
		private _obj = _x;

		if (isNil "_obj") exitWith {false};
		if !(_obj isEqualType objNull) exitWith {false};
		if (isNull _obj) exitWith {false};

		true
	};

	if (_operators isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: ZERO OPERATORS. Synced objects given: %1", _syncedObjs] DLOG
	};

	private _sidesStr = LGVAR ["operatorSides", ""];
	private _sides = (_sidesStr splitString " ,.;:[](){}") apply {
		private _compile = call compile _x;
		if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
			false
		} else {
			_compile
		};
	};
	_sides = _sides select {_x isEqualType west};

	if (_sides isEqualTo []) then {
		_sides = [side (_operators#0)];
	};

	if (_sides isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %1", _sidesStr] DLOG
	};

	private _turretsCustom = LGVAR ["operatorTurretsCustom", ""];
	if !(_turretsCustom isEqualTo "") then {
		_turretsCustom = call compile _turretsCustom;
	};
	if (isNil "_turretsCustom") then {
		_turretsCustom = [];
	};
	if !(_turretsCustom isEqualType []) then {
		_turretsCustom = [];
	};

	private _nvgTi = [SELECT_DEF("operatorHasNvg", 1), SELECT_DEF("operatorHasTI", 1)];

	private _name = LGVAR ["operatorName", ""];
	private _canMoveCam = SELECT_DEF("operatorCanMoveCamera", 1);
	private _smoothZoom = BOOL("operatorSmoothZoom", 1);

	[
		_operators,
		_sides,
		_turretsCustom,
		_nvgTi,
		_name,
		[
			_canMoveCam,
			_smoothZoom
		]
	] call CFM_fnc_setOperator;
};

