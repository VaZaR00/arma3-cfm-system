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

	if (_logic getVariable ["CFM_monInitExecuted", false]) exitWith {};
	_logic setVariable ["CFM_monInitExecuted", true];

	sleep 0.05;

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

	private _textureSelections = trim (LGVAR ["textureSelections", ""]);
	private _seatKeys = trim (LGVAR ["seatKeys", ""]);

	private _fnc_scanModifiers = {
		params ["_str", ["_checkKeywords", false]];
		private _s = trim _str;
		if (_s isEqualTo "") exitWith {[false, false, false, false]};
		private _wsChars = [" ", toString [9], toString [10], toString [13]];
		private _skipChars = _wsChars + [","];
		private _sLen = count _s;

		private _fnc_findClosingBracket = {
			params ["_startIdx"];
			private _depth = 0;
			private _parenDepth = 0;
			private _inDQ = false;
			private _inSQ = false;
			private _endIdx = -1;
			for "_k" from _startIdx to (_sLen - 1) do {
				private _c = _s select [_k, 1];
				if (_c isEqualTo """" && {!_inSQ}) then {
					_inDQ = !_inDQ;
				} else {
					if (_c isEqualTo "'" && {!_inDQ}) then {
						_inSQ = !_inSQ;
					} else {
						if (!_inDQ && {!_inSQ}) then {
							if (_c isEqualTo "(") then {
								_parenDepth = _parenDepth + 1;
							} else {
								if (_c isEqualTo ")" && {_parenDepth > 0}) then {
									_parenDepth = _parenDepth - 1;
								} else {
									if (_parenDepth == 0) then {
										if (_c isEqualTo "[") then {_depth = _depth + 1};
										if (_c isEqualTo "]") then {
											_depth = _depth - 1;
											if (_depth == 0) exitWith {_endIdx = _k};
										};
									};
								};
							};
						};
					};
				};
			};
			_endIdx
		};

		private _fnc_findTokenEnd = {
			params ["_startIdx"];
			private _depth = 0;
			private _parenDepth = 0;
			private _inDQ = false;
			private _inSQ = false;
			private _k = _startIdx;
			while {_k < _sLen} do {
				private _c = _s select [_k, 1];
				if (_c isEqualTo """" && {!_inSQ}) then {
					_inDQ = !_inDQ;
				} else {
					if (_c isEqualTo "'" && {!_inDQ}) then {
						_inSQ = !_inSQ;
					} else {
						if (!_inDQ && {!_inSQ}) then {
							if (_c isEqualTo "(") then {
								_parenDepth = _parenDepth + 1;
							} else {
								if (_c isEqualTo ")" && {_parenDepth > 0}) then {
									_parenDepth = _parenDepth - 1;
								} else {
									if (_parenDepth == 0) then {
										if (_c isEqualTo "[") then {_depth = _depth + 1};
										if (_c isEqualTo "]" && {_depth > 0}) then {_depth = _depth - 1};
										if (_depth == 0 && {_c in _skipChars}) exitWith {};
									};
								};
							};
						};
					};
				};
				_k = _k + 1;
			};
			_k
		};

		private _pos = 0;
		private _hasKeyword = false;
		private _hasPlainOrAdd = false;
		private _hasRewrite = false;
		private _hasRemove = false;

		while {_pos < _sLen} do {
			while {_pos < _sLen && {(_s select [_pos, 1]) in _skipChars}} do {
				_pos = _pos + 1;
			};
			if (_pos >= _sLen) exitWith {};

			private _ch = _s select [_pos, 1];
			private _rest = _s select [_pos];

			if (_checkKeywords) then {
				if ((toLower (_rest select [0, 3])) isEqualTo "all" && {(_pos + 3 >= _sLen) || {!((_s select [_pos + 3, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
					_hasKeyword = true;
					_pos = _pos + 3;
					continue;
				};
				if ((toLower (_rest select [0, 7])) isEqualTo "default" && {(_pos + 7 >= _sLen) || {!((_s select [_pos + 7, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
					_hasKeyword = true;
					_pos = _pos + 7;
					continue;
				};
			};

			if (_ch in ["+", "-", "!"]) then {
				switch (_ch) do {
					case "+": { _hasPlainOrAdd = true; };
					case "!": { _hasRewrite = true; };
					case "-": { _hasRemove = true; };
				};
				private _j = _pos + 1;
				while {_j < _sLen && {(_s select [_j, 1]) in _wsChars}} do {
					_j = _j + 1;
				};
				if (_j < _sLen && {(_s select [_j, 1]) isEqualTo "["}) then {
					private _endIdx = [_j] call _fnc_findClosingBracket;
					_pos = if (_endIdx >= _j) then {_endIdx + 1} else {_sLen};
				} else {
					_pos = [_j] call _fnc_findTokenEnd;
				};
				continue;
			};

			_hasPlainOrAdd = true;
			if (_ch isEqualTo "[") then {
				private _endIdx = [_pos] call _fnc_findClosingBracket;
				_pos = if (_endIdx >= _pos) then {_endIdx + 1} else {_sLen};
			} else {
				_pos = [_pos] call _fnc_findTokenEnd;
			};
		};

		[_hasKeyword, _hasPlainOrAdd, _hasRewrite, _hasRemove]
	};

	([_seatKeys, true] call _fnc_scanModifiers) params ["_seatHasKeyword", "_seatHasPlainOrAdd", "_seatHasRewrite", "_seatHasRemove"];
	([_textureSelections, false] call _fnc_scanModifiers) params ["", "_texHasPlainOrAdd", "_texHasRewrite", "_texHasRemove"];

	private _isEmpty = (_seatKeys isEqualTo "") && {_textureSelections isEqualTo ""};
	private _hasKeyword = _seatHasKeyword;
	private _hasPlainOrAdd = _seatHasPlainOrAdd || _texHasPlainOrAdd;
	private _hasRewrite = _seatHasRewrite || _texHasRewrite;
	private _hasRemove = _seatHasRemove || _texHasRemove;
	private _isOnlyRemove = _hasRemove && {!_isEmpty} && {!_hasKeyword} && {!_hasPlainOrAdd} && {!_hasRewrite};

	{
		_x setVariable ["CFM_syncedMonitorModulesCount", (_x getVariable ["CFM_syncedMonitorModulesCount", 0]) + 1];
		if (_isOnlyRemove) then {
			if (isNil {_x getVariable "CFM_allSyncedModulesOnlyRemove"}) then {
				_x setVariable ["CFM_allSyncedModulesOnlyRemove", true];
			};
		} else {
			_x setVariable ["CFM_allSyncedModulesOnlyRemove", false];
		};
	} forEach _monitors;

	private _tierDelay = call {
		if (_isEmpty || _hasKeyword) exitWith {0.05};
		if (!_hasRewrite && {!_hasRemove}) exitWith {0.10};
		if (_hasRewrite) exitWith {0.15};
		0.20
	};
	sleep _tierDelay;

	[
		_monitors,
		_sides,
		_allowedOperators,
		_allowedOperatorsTypes,
		BOOL("IsHandMonitorDisplay", 0),
		_seatKeys,
		SELECT_DEF("isVehSeatTablet", -1),
		BOOL("monitorcanSwitchNvg", 1),
		BOOL("monitorCanSwitchTi", 1),
		BOOL("monitorCanSwitchTurret", 1),
		BOOL("monitorCanZoom", 1),
		BOOL("monitorCanFullScreen", 1),
		BOOL("monitorCanConnectDrone", 1),
		BOOL("monitorCanFix", 1),
		BOOL("monitorCanTurnOffLocal", 1),
		BOOL("monitorHasPassword", 1),
		LGVAR ["ScreenResolution", ""],
		_textureSelections
	] call CFM_fnc_setMonitor;
};
