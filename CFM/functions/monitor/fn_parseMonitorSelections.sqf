/*
    Function: CFM_fnc_parseMonitorSelections
    Author: Vazar
    Description: Parses textureSelections and seatKeys into deterministic monitor instance specs:
                 [[_texSel, _seatKey, _isVehSeatTablet, _isHandTablet, _seatKeys, _controlSeatKeys, _opMode, _hasExplicitTexSel, _pipCount], ...]
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_textureSelections", ""],
	["_seatKeys", ""],
	["_isVehSeatTablet", false],
	["_isHandTablet", false]
];

if (_isHandTablet) exitWith {
	[[NO_TEXTURE_SELECTION, "", false, true, [], [], "BASE_EMPTY", false, 1]]
};

private _wsChars = [" ", toString [9], toString [10], toString [13]];
private _skipChars = _wsChars + [","];

private _fnc_findClosingBracket = {
	params ["_str", "_startIdx"];
	private _len = count _str;
	private _depth = 0;
	private _parenDepth = 0;
	private _inDQ = false;
	private _inSQ = false;
	private _endIdx = -1;
	for "_k" from _startIdx to (_len - 1) do {
		private _c = _str select [_k, 1];
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
	params ["_str", "_startIdx"];
	private _len = count _str;
	private _depth = 0;
	private _parenDepth = 0;
	private _inDQ = false;
	private _inSQ = false;
	private _k = _startIdx;
	while {_k < _len} do {
		private _c = _str select [_k, 1];
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

// Split comma-separated tokens outside [] / () brackets and quotes
private _fnc_splitTopLevel = {
	params ["_input"];
	private _trimmed = trim _input;
	if (_trimmed isEqualTo "") exitWith {[]};
	private _tokens = [];
	private _cur = "";
	private _depth = 0;
	private _parenDepth = 0;
	private _inDQuote = false;
	private _inSQuote = false;
	for "_i" from 0 to ((count _trimmed) - 1) do {
		private _ch = _trimmed select [_i, 1];
		private _handled = false;
		if (_ch isEqualTo """" && {!_inSQuote}) then {
			_inDQuote = !_inDQuote;
		} else {
			if (_ch isEqualTo "'" && {!_inDQuote}) then {
				_inSQuote = !_inSQuote;
			} else {
				if (!_inDQuote && {!_inSQuote}) then {
					if (_ch isEqualTo "(") then {
						_parenDepth = _parenDepth + 1;
					} else {
						if (_ch isEqualTo ")" && {_parenDepth > 0}) then {
							_parenDepth = _parenDepth - 1;
						} else {
							if (_parenDepth == 0) then {
								if (_ch isEqualTo "[") then {_depth = _depth + 1};
								if (_ch isEqualTo "]" && {_depth > 0}) then {_depth = _depth - 1};
								if (_ch isEqualTo "," && {_depth == 0}) then {
									private _tok = trim _cur;
									if !(_tok isEqualTo "") then {_tokens pushBack _tok};
									_cur = "";
									_handled = true;
								};
							};
						};
					};
				};
			};
		};
		if (!_handled) then {_cur = _cur + _ch};
	};
	private _last = trim _cur;
	if !(_last isEqualTo "") then {_tokens pushBack _last};
	_tokens
};

private _fnc_tryParseArray = {
	params ["_str"];
	private _s = trim _str;
	if (_s isEqualTo "") exitWith {[]};
	private _len = count _s;
	if (_len < 2 || {!((_s select [0, 1]) isEqualTo "[")} || {!((_s select [_len - 1, 1]) isEqualTo "]")}) exitWith {nil};

	// Verify the opening '[' at index 0 matches the closing ']' at index _len - 1
	private _depth = 0;
	private _parenDepth = 0;
	private _inDQ = false;
	private _inSQ = false;
	private _closesAtEnd = true;
	for "_k" from 0 to (_len - 1) do {
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
									if (_depth == 0 && {_k < (_len - 1)}) then {_closesAtEnd = false};
								};
							};
						};
					};
				};
			};
		};
		if (!_closesAtEnd) exitWith {};
	};
	if (!_closesAtEnd || {_depth != 0}) exitWith {nil};

	private _innerStr = trim (_s select [1, _len - 2]);
	if (_innerStr isEqualTo "") exitWith {[]};

	private _parts = [_innerStr] call _fnc_splitTopLevel;
	private _res = [];
	private _ok = true;
	{
		private _tok = _x;
		private _firstCh = _tok select [0, 1];
		if (_firstCh isEqualTo "[") then {
			private _sub = [_tok] call _fnc_tryParseArray;
			if (isNil "_sub") exitWith {_ok = false};
			_res pushBack _sub;
		} else {
			if (_firstCh in ["""", "'"]) then {
				_res pushBack (_tok select [1, ((count _tok) - 2) max 0]);
			} else {
				if (_tok regexMatch "^-?[0-9]+$") then {
					_res pushBack (parseNumber _tok);
				} else {
					_res pushBack _tok;
				};
			};
		};
		if (!_ok) exitWith {};
	} forEach _parts;
	if (_ok) exitWith {_res};
	nil
};

// 1. Parse textureSelections -> add, rewrite, remove arrays of non-negative integers
private _texAddSels = [];
private _texRewriteSels = [];
private _texRemoveSels = [];

private _fnc_collectTexNums = {
	params ["_rawStr", "_dest"];
	private _trimmed = trim _rawStr;
	if (_trimmed isEqualTo "") exitWith {};
	if ((_trimmed select [0, 1]) isEqualTo "[") then {
		private _arr = [_trimmed] call _fnc_tryParseArray;
		if (!isNil "_arr" && {_arr isEqualType []}) then {
			{
				if (_x isEqualType 0 && {_x >= 0}) then {
					_dest pushBackUnique (floor _x);
				} else {
					if (_x isEqualType "") then {
						private _ts = trim _x;
						if (_ts regexMatch "^#[0-9]+$") then {
							_dest pushBackUnique (floor (parseNumber (_ts select [1])));
						} else {
							if (_ts regexMatch "^[0-9]+$") then {
								_dest pushBackUnique (floor (parseNumber _ts));
							};
						};
					};
				};
			} forEach _arr;
		};
	} else {
		private _tokens = [_trimmed] call _fnc_splitTopLevel;
		{
			private _subTokens = _x splitString (" " + toString [9] + toString [10] + toString [13]);
			{
				private _t = _x;
				private _firstCh = _t select [0, 1];
				if (_firstCh in ["""", "'"]) then {
					_t = _t select [1, ((count _t) - 2) max 0];
				};
				_t = trim _t;
				if (_t regexMatch "^#[0-9]+$") then {
					_t = _t select [1];
				};
				if (_t regexMatch "^-?[0-9]+$") then {
					private _num = parseNumber _t;
					if (_num >= 0) then {_dest pushBackUnique (floor _num)};
				};
			} forEach _subTokens;
		} forEach _tokens;
	};
};

if (_textureSelections isEqualType 0) then {
	if (_textureSelections >= 0) then {_texAddSels pushBack (floor _textureSelections)};
} else {
	if (_textureSelections isEqualType []) then {
		{
			if (_x isEqualType 0 && {_x >= 0}) then {
				_texAddSels pushBackUnique (floor _x);
			} else {
				if (_x isEqualType "") then {
					private _ts = trim _x;
					if (_ts regexMatch "^#[0-9]+$") then {
						_texAddSels pushBackUnique (floor (parseNumber (_ts select [1])));
					} else {
						if (_ts regexMatch "^[0-9]+$") then {
							_texAddSels pushBackUnique (floor (parseNumber _ts));
						};
					};
				};
			};
		} forEach _textureSelections;
	} else {
		if (_textureSelections isEqualType "") then {
			private _s = trim _textureSelections;
			if !(_s isEqualTo "") then {
				private _sLen = count _s;
				private _pos = 0;
				while {_pos < _sLen} do {
					while {_pos < _sLen && {(_s select [_pos, 1]) in _skipChars}} do {
						_pos = _pos + 1;
					};
					if (_pos >= _sLen) exitWith {};
					private _ch = _s select [_pos, 1];
					if (_ch in ["+", "-", "!"]) then {
						private _destArr = switch (_ch) do {
							case "+": {_texAddSels};
							case "-": {_texRemoveSels};
							case "!": {_texRewriteSels};
						};
						private _j = _pos + 1;
						while {_j < _sLen && {(_s select [_j, 1]) in _wsChars}} do {
							_j = _j + 1;
						};
						if (_j < _sLen && {(_s select [_j, 1]) isEqualTo "["}) then {
							private _endIdx = [_s, _j] call _fnc_findClosingBracket;
							if (_endIdx > _j) then {
								private _inner = _s select [_j + 1, _endIdx - _j - 1];
								[_inner, _destArr] call _fnc_collectTexNums;
								_pos = _endIdx + 1;
							} else {
								_pos = _sLen;
							};
						} else {
							private _endIdx = [_s, _j] call _fnc_findTokenEnd;
							private _tok = trim (_s select [_j, _endIdx - _j]);
							[_tok, _destArr] call _fnc_collectTexNums;
							_pos = _endIdx;
						};
						continue;
					};
					if (_ch isEqualTo "[") then {
						private _endIdx = [_s, _pos] call _fnc_findClosingBracket;
						if (_endIdx >= _pos) then {
							[_s select [_pos, _endIdx - _pos + 1], _texAddSels] call _fnc_collectTexNums;
							_pos = _endIdx + 1;
						} else {
							_pos = _sLen;
						};
					} else {
						private _endIdx = [_s, _pos] call _fnc_findTokenEnd;
						[_s select [_pos, _endIdx - _pos], _texAddSels] call _fnc_collectTexNums;
						_pos = _endIdx;
					};
				};
			};
		};
	};
};

_texRewriteSels = _texRewriteSels select {!(_x in _texRemoveSels)};
_texAddSels = _texAddSels select {!(_x in _texRemoveSels) && {!(_x in _texRewriteSels)}};

// 2. Parse seatKeys -> raw entries
// Parses the 2nd element of [seatOrSeatList, second(, ctrl)].
// Returns: [_valid, _isTexSel, _texSel, _pipCount, _isAllPipSentinel]
// - "#0", "#2"     -> [true, true, 0/2, 1, false]      (explicit 3D texture selection)
// - -1, "-1"       -> [true, false, -1, 1, true]       (explicit 1 PiP instance / all PiP for REMOVE)
// - 2, "2", 1, "1" -> [true, false, -1, 2/1, false]    (explicit N PiP instances)
// - 0, "0"         -> [true, false, -1, 0, false]      (count 0 -> ignored with warning, NOT texSel 0)
private _fnc_parsePairSecond = {
	params ["_val"];
	if (_val isEqualType 0) exitWith {
		private _n = floor _val;
		if (_n == NO_TEXTURE_SELECTION) exitWith {[true, false, NO_TEXTURE_SELECTION, 1, true]};
		if (_n >= 0) exitWith {[true, false, NO_TEXTURE_SELECTION, _n, false]};
		[false, false, NO_TEXTURE_SELECTION, 0, false]
	};
	if (_val isEqualType "") exitWith {
		private _s = trim _val;
		if (_s regexMatch "^#[0-9]+$") exitWith {
			private _texSel = floor (parseNumber (_s select [1]));
			[true, true, _texSel, 1, false]
		};
		if (_s regexMatch "^-?[0-9]+$") exitWith {
			private _n = floor (parseNumber _s);
			if (_n == NO_TEXTURE_SELECTION) exitWith {[true, false, NO_TEXTURE_SELECTION, 1, true]};
			if (_n >= 0) exitWith {[true, false, NO_TEXTURE_SELECTION, _n, false]};
			[false, false, NO_TEXTURE_SELECTION, 0, false]
		};
		[false, false, NO_TEXTURE_SELECTION, 0, false]
	};
	[false, false, NO_TEXTURE_SELECTION, 0, false]
};

// True for single-seat array descriptors: [0], [0, 1], [-1], ["turret", [0]], ["cargo", 0]
private _fnc_isSingleSeatArrayDesc = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {_arr isEqualTo []}) exitWith {false};
	// [0], [0, 1], [-1] -> numeric turret path
	if (({_x isEqualType 0} count _arr) == (count _arr)) exitWith {true};
	// ["turret", [0]] or ["cargo", 0] style single descriptor
	if ((count _arr) == 2 && {(_arr select 0) isEqualType ""}) exitWith {
		private _head = toLower (_arr select 0);
		(_head isEqualTo "turret" && {(_arr select 1) isEqualType []}) ||
		{_head isEqualTo "cargo" && {(_arr select 1) isEqualType 0}}
	};
	false
};

private _fnc_isPairEntryBasic = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {(count _arr) != 2}) exitWith {false};
	private _first = _arr select 0;
	private _second = _arr select 1;
	// Preserve numeric turret paths such as [0, 1]
	if (_first isEqualType 0 && {_second isEqualType 0}) exitWith {false};
	([_second] call _fnc_parsePairSecond) select 0
};

// True for a list of seat descriptors used in shared PiP entries:
// e.g. ["cargo_0", "cargo_1"], ["cargo"], [[0], "cargo_0"]
private _fnc_isSeatList = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {_arr isEqualTo []}) exitWith {false};
	if ([_arr] call _fnc_isSingleSeatArrayDesc) exitWith {false};
	if ([_arr] call _fnc_isPairEntryBasic) exitWith {false};
	({
		(_x isEqualType "") || {_x isEqualType 0} || {[_x] call _fnc_isSingleSeatArrayDesc}
	} count _arr) == (count _arr)
};

// True for shared PiP monitor entries:
// [[seat1, seat2, ...], -1|count] or [[seat1, seat2, ...], -1|count, controlSeatOrList]
private _fnc_isSharedGroupEntry = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {!((count _arr) in [2, 3])}) exitWith {false};
	private _first = _arr select 0;
	private _second = _arr select 1;
	if !([_first] call _fnc_isSeatList) exitWith {false};
	([_second] call _fnc_parsePairSecond) params ["_valid", "_isTexSel"];
	_valid && {!_isTexSel}
};

private _fnc_isInvalidSharedTexEntry = {
	params ["_item"];
	if (!(_item isEqualType []) || {!((count _item) in [2, 3])}) exitWith {false};
	if !([_item select 0] call _fnc_isSeatList) exitWith {false};
	([_item select 1] call _fnc_parsePairSecond) params ["_valid", "_isTexSel"];
	_valid && {_isTexSel}
};

private _fnc_isPairEntry = {
	params ["_arr"];
	if !([_arr] call _fnc_isPairEntryBasic) exitWith {false};
	!([_arr select 0] call _fnc_isSeatList)
};

private _fnc_isSingleTurretOrDesc = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {_arr isEqualTo []}) exitWith {false};
	if ([_arr] call _fnc_isSharedGroupEntry) exitWith {true};
	if ([_arr] call _fnc_isInvalidSharedTexEntry) exitWith {true};
	if ([_arr] call _fnc_isPairEntry) exitWith {true};
	[_arr] call _fnc_isSingleSeatArrayDesc
};

private _fnc_normalizeArrayItems = {
	params ["_arr"];
	if (_arr isEqualTo []) exitWith {[]};
	if ([_arr] call _fnc_isSingleTurretOrDesc) exitWith {[_arr]};
	_arr
};

private _fnc_parseListString = {
	params ["_listStr"];
	private _items = [];
	private _tokens = [_listStr] call _fnc_splitTopLevel;
	{
		private _tok = _x;
		private _firstCh = _tok select [0, 1];
		if (_firstCh isEqualTo "[") then {
			private _parsed = [_tok] call _fnc_tryParseArray;
			if (!isNil "_parsed" && {_parsed isEqualType []}) then {
				_items append ([_parsed] call _fnc_normalizeArrayItems);
			};
		} else {
			if (_firstCh in ["""", "'"]) then {
				private _unquoted = _tok select [1, ((count _tok) - 2) max 0];
				if !(_unquoted isEqualTo "") then {_items pushBack _unquoted};
			} else {
				if (_tok regexMatch "^-?[0-9]+$") then {
					_items pushBack (parseNumber _tok);
				} else {
					if !(_tok isEqualTo "") then {_items pushBack _tok};
				};
			};
		};
	} forEach _tokens;
	_items
};

private _fnc_parseModifierItems = {
	params ["_body", ["_fromBrackets", true]];
	private _candidate = [format ["[%1]", _body]] call _fnc_tryParseArray;
	if (
		!isNil "_candidate" &&
		{_candidate isEqualType []} &&
		{
			([_candidate] call _fnc_isSharedGroupEntry) ||
			{[_candidate] call _fnc_isInvalidSharedTexEntry} ||
			{[_candidate] call _fnc_isPairEntry} ||
			{_fromBrackets && {[_candidate] call _fnc_isSingleSeatArrayDesc}}
		}
	) exitWith {
		[_candidate]
	};
	[_body] call _fnc_parseListString
};

private _isEmptyKeys = (_texAddSels isEqualTo [])
	&& {_texRewriteSels isEqualTo []}
	&& {_texRemoveSels isEqualTo []}
	&& {
		((_seatKeys isEqualType "") && {(trim _seatKeys) isEqualTo ""}) ||
		{(_seatKeys isEqualType []) && {_seatKeys isEqualTo []}}
	};

private _baseMode = ""; // "", "DEFAULT", "ALL"
private _baseOpMode = "BASE";
private _sawModifierToken = false;
private _addBodies = [];
private _removeBodies = [];
private _rewriteBodies = [];
private _rawSeatItems = [];

if (_seatKeys isEqualType "") then {
	private _s = trim _seatKeys;
	if (_s isEqualTo "") then {
		if (_isEmptyKeys && {_isVehSeatTablet}) then {
			_baseMode = "DEFAULT";
			_baseOpMode = "BASE_EMPTY";
		};
	} else {
		private _sLen = count _s;
		private _pos = 0;

		while {_pos < _sLen} do {
			while {_pos < _sLen && {(_s select [_pos, 1]) in _skipChars}} do {
				_pos = _pos + 1;
			};
			if (_pos >= _sLen) exitWith {};

			private _ch = _s select [_pos, 1];
			private _rest = _s select [_pos];

			if ((toLower (_rest select [0, 3])) isEqualTo "all" && {(_pos + 3 >= _sLen) || {!((_s select [_pos + 3, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
				_baseMode = "ALL";
				_baseOpMode = "BASE";
				_sawModifierToken = true;
				_pos = _pos + 3;
				continue;
			};
			if ((toLower (_rest select [0, 7])) isEqualTo "default" && {(_pos + 7 >= _sLen) || {!((_s select [_pos + 7, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
				if (_baseMode isEqualTo "") then {
					_baseMode = "DEFAULT";
					_baseOpMode = "BASE";
				};
				_sawModifierToken = true;
				_pos = _pos + 7;
				continue;
			};

			if (_ch in ["+", "-", "!"]) then {
				private _j = _pos + 1;
				while {_j < _sLen && {(_s select [_j, 1]) in _wsChars}} do {
					_j = _j + 1;
				};
				if (_j < _sLen && {(_s select [_j, 1]) isEqualTo "["}) then {
					private _endIdx = [_s, _j] call _fnc_findClosingBracket;
					if (_endIdx > _j) then {
						private _inner = _s select [_j + 1, _endIdx - _j - 1];
						switch (_ch) do {
							case "+": { _addBodies pushBack [_inner, true]; };
							case "-": { _removeBodies pushBack [_inner, true]; };
							case "!": { _rewriteBodies pushBack [_inner, true]; };
						};
						_sawModifierToken = true;
						_pos = _endIdx + 1;
					} else {
						_pos = _sLen;
					};
				} else {
					if (_j < _sLen) then {
						private _endIdx = [_s, _j] call _fnc_findTokenEnd;
						private _tok = trim (_s select [_j, _endIdx - _j]);
						if !(_tok isEqualTo "") then {
							switch (_ch) do {
								case "+": { _addBodies pushBack [_tok, false]; };
								case "-": { _removeBodies pushBack [_tok, false]; };
								case "!": { _rewriteBodies pushBack [_tok, false]; };
							};
							_sawModifierToken = true;
						};
						_pos = _endIdx;
					} else {
						_pos = _sLen;
					};
				};
				continue;
			};

			if (_ch isEqualTo "[") then {
				private _endIdx = [_s, _pos] call _fnc_findClosingBracket;
				if (_endIdx >= _pos) then {
					private _tok = _s select [_pos, _endIdx - _pos + 1];
					_rawSeatItems append ([_tok] call _fnc_parseListString);
					_pos = _endIdx + 1;
				} else {
					_pos = _sLen;
				};
			} else {
				private _endIdx = [_s, _pos] call _fnc_findTokenEnd;
				private _tok = trim (_s select [_pos, _endIdx - _pos]);
				if !(_tok isEqualTo "") then {
					_rawSeatItems append ([_tok] call _fnc_parseListString);
				};
				_pos = _endIdx;
			};
		};
	};
} else {
	if (_seatKeys isEqualType []) then {
		if (_seatKeys isEqualTo []) then {
			if (_isEmptyKeys && {_isVehSeatTablet}) then {
				_baseMode = "DEFAULT";
				_baseOpMode = "BASE_EMPTY";
			};
		} else {
			if ((count _seatKeys == 1) && {(_seatKeys select 0) isEqualType ""} && {(toLower trim (_seatKeys select 0)) in ["all", "default"]}) then {
				_baseMode = ["DEFAULT", "ALL"] select ((toLower trim (_seatKeys select 0)) isEqualTo "all");
				_baseOpMode = "BASE";
				_sawModifierToken = true;
			} else {
				_rawSeatItems = [_seatKeys] call _fnc_normalizeArrayItems;
			};
		};
	} else {
		if (_seatKeys isEqualType 0) then {
			_rawSeatItems = [_seatKeys];
		};
	};
};

if (
	(_baseMode isEqualTo "") &&
	{_isVehSeatTablet} &&
	{_sawModifierToken} &&
	{_rawSeatItems isEqualTo []} &&
	{_texAddSels isEqualTo []} &&
	{_texRewriteSels isEqualTo []} &&
	{_texRemoveSels isEqualTo []}
) then {
	private _existingCount = count (_monitor getVariable ["CFM_monitorInstanceKeysMap", createHashMap]);
	private _syncedModsCount = _monitor getVariable ["CFM_syncedMonitorModulesCount", 0];
	private _allOnlyRemove = _monitor getVariable ["CFM_allSyncedModulesOnlyRemove", false];
	if (_existingCount == 0 && {(_syncedModsCount <= 1) || _allOnlyRemove}) then {
		_baseMode = "DEFAULT";
		_baseOpMode = "BASE";
	};
};

// 3. Build canonical seat descriptors from fullCrew
private _allCrew = if (IS_OBJ(_monitor)) then {fullCrew [_monitor, "", true]} else {[]};
private _crewInfo = _allCrew apply {
	private _key = [_x] call CFM_fnc_getCrewSeatKey;
	[_key, toLower (_x param [1, ""]), _x param [2, -1], _x param [3, []]]
};

private _fnc_resolveSeatDesc = {
	params ["_desc"];
	private _keys = [];
	private _isSubstringPattern = false;
	private _pattern = "";
	if (_desc isEqualType "") then {
		private _d = toLower (trim _desc);
		private _dLen = count _d;
		if (_dLen >= 2 && {(_d select [0, 1]) isEqualTo "("} && {(_d select [_dLen - 1, 1]) isEqualTo ")"}) then {
			_isSubstringPattern = true;
			_pattern = trim (_d select [1, _dLen - 2]);
		};
	};
	{
		_x params ["_key", "_role", "_cargoIdx", "_turretPath"];
		if !(_key isEqualTo "") then {
			private _matched = false;
			if (_desc isEqualType "") then {
				if (_isSubstringPattern) then {
					if !(_pattern isEqualTo "") then {
						_matched = (_pattern in (toLower _key)) || {_pattern in _role};
					};
				} else {
					private _d = toLower (trim _desc);
					_matched = (_d isEqualTo (toLower _key)) || {_d isEqualTo _role};
				};
			} else {
				if (_desc isEqualType []) then {
					_matched = (_desc isEqualTo _turretPath)
						|| {(_role isEqualTo "driver") && {_desc isEqualTo [-1]}}
						|| {((count _desc) == 2) && {(_desc select 0) isEqualType ""} && {toLower (_desc select 0) isEqualTo "turret"} && {(_desc select 1) isEqualTo _turretPath}}
						|| {(_role isEqualTo toLower (_desc param [0, ""])) && {((_desc param [1, -999]) isEqualTo _turretPath) || {(_desc param [1, -999]) isEqualTo _cargoIdx}}};
				} else {
					if (_desc isEqualType 0) then {
						_matched = (_turretPath isEqualTo [_desc]) || {(_role isEqualTo "driver") && {_desc == -1}};
					};
				};
			};
			if (_matched) then {_keys pushBackUnique _key};
		};
	} forEach _crewInfo;

	if (_keys isEqualTo [] && {_crewInfo isEqualTo []} && {_desc isEqualType ""} && {!_isSubstringPattern}) then {
		private _d = trim _desc;
		if !(_d isEqualTo "") then {_keys pushBack _d};
	};
	_keys
};

private _fnc_resolveSharedGroup = {
	params ["_entry"];
	private _seatDescList = _entry select 0;
	private _hasControlParam = (count _entry) >= 3;
	private _controlParam = if (_hasControlParam) then {_entry select 2} else {nil};

	private _resolvedSeats = [];
	{
		{
			_resolvedSeats pushBackUnique _x;
		} forEach ([_x] call _fnc_resolveSeatDesc);
	} forEach _seatDescList;

	private _resolvedControls = [];
	if (_hasControlParam && {!isNil "_controlParam"}) then {
		private _ctrlDescs = if ([_controlParam] call _fnc_isSeatList) then {
			_controlParam
		} else {
			if (_controlParam isEqualType [] && {_controlParam isEqualTo []}) then {[]} else {[_controlParam]}
		};
		{
			{
				_resolvedControls pushBackUnique _x;
				_resolvedSeats pushBackUnique _x;
			} forEach ([_x] call _fnc_resolveSeatDesc);
		} forEach _ctrlDescs;

		if (_resolvedControls isEqualTo []) then {
			diag_log format ["[CFM] Shared monitor control seat(s) '%1' resolved to no valid seats on %2; monitor will be view-only", _controlParam, _monitor];
			_resolvedControls = ["__NO_CONTROLLER__"];
		};
	};

	[_resolvedSeats, _resolvedControls]
};

private _seatSpecsRaw = [];
private _baseKeys = [];
if !(_baseMode isEqualTo "") then {
	{
		_x params ["_key", "_role"];
		if !(_key isEqualTo "") then {
			if (_baseMode isEqualTo "ALL" || {_role in ["driver", "gunner", "commander"]}) then {
				_baseKeys pushBackUnique _key;
			};
		};
	} forEach _crewInfo;
};

private _removeFullSeatsSet = createHashMap;
private _removePairSet = createHashMap;
private _removePipCountMap = createHashMap;
private _removeSpecs = [];
{
	_x params ["_body", "_fromBrackets"];
	private _remItems = [_body, _fromBrackets] call _fnc_parseModifierItems;
	{
		if ([_x] call _fnc_isSharedGroupEntry) then {
			([_x select 1] call _fnc_parsePairSecond) params ["", "", "", "_parsedCount", "_isAllPip"];
			if (!_isAllPip && {_parsedCount <= 0}) then {
				diag_log format ["[CFM] Monitor count 0 ignored for shared entry %1 on %2 (use ""#0"" for texture selection 0)", _x, _monitor];
			} else {
				([_x] call _fnc_resolveSharedGroup) params ["_grpSeats"];
				if (_grpSeats isNotEqualTo []) then {
					private _remCnt = if (_isAllPip) then {-1} else {_parsedCount};
					{
						if (_isAllPip) then {
							_removePairSet set [format ["%1|%2", _x, NO_TEXTURE_SELECTION], true];
						} else {
							_removePipCountMap set [_x, (_removePipCountMap getOrDefault [_x, 0]) + _parsedCount];
						};
					} forEach _grpSeats;
					_removeSpecs pushBack [NO_TEXTURE_SELECTION, _grpSeats joinString ", ", true, false, _grpSeats, [], "REMOVE", true, _remCnt];
				};
			};
		} else {
			if ([_x] call _fnc_isInvalidSharedTexEntry) then {
				diag_log format ["[CFM] Shared multi-seat monitor entry %1 only supports PiP (count or -1); ignoring on %2", _x, _monitor];
			} else {
				private _seatDesc = _x;
				private _texSel = NO_TEXTURE_SELECTION;
				private _hasExp = false;
				private _remCnt = -1;
				private _skipItem = false;
				if ([_x] call _fnc_isPairEntry) then {
					_seatDesc = _x select 0;
					([_x select 1] call _fnc_parsePairSecond) params ["", "_isTexSel", "_parsedTexSel", "_parsedCount", "_isAllPip"];
					if (!_isTexSel && {!_isAllPip} && {_parsedCount <= 0}) then {
						diag_log format ["[CFM] Monitor count 0 ignored for seat %1 on %2 (use ""#0"" for texture selection 0)", _seatDesc, _monitor];
						_skipItem = true;
					} else {
						_texSel = if (_isTexSel) then {_parsedTexSel} else {NO_TEXTURE_SELECTION};
						_hasExp = true;
						_remCnt = if (_isTexSel) then {1} else {if (_isAllPip) then {-1} else {_parsedCount}};
					};
				};
				if !(_skipItem) then {
					{
						if (_hasExp) then {
							if (_texSel >= 0 || {_remCnt < 0}) then {
								_removePairSet set [format ["%1|%2", _x, _texSel], true];
							} else {
								_removePipCountMap set [_x, (_removePipCountMap getOrDefault [_x, 0]) + _remCnt];
							};
						} else {
							_removeFullSeatsSet set [_x, true];
						};
						_removeSpecs pushBack [_texSel, _x, true, false, [_x], [], "REMOVE", _hasExp, _remCnt];
					} forEach ([_seatDesc] call _fnc_resolveSeatDesc);
				};
			};
		};
	} forEach _remItems;
} forEach _removeBodies;

private _rewriteMap = createHashMap;
private _rewriteSharedGroups = [];
private _rewriteSharedSeatSet = createHashMap;
{
	_x params ["_body", "_fromBrackets"];
	private _rwItems = [_body, _fromBrackets] call _fnc_parseModifierItems;
	{
		if ([_x] call _fnc_isSharedGroupEntry) then {
			([_x select 1] call _fnc_parsePairSecond) params ["", "", "", "_parsedCount"];
			if (_parsedCount <= 0) then {
				diag_log format ["[CFM] Monitor count 0 ignored for shared entry %1 on %2 (use ""#0"" for texture selection 0)", _x, _monitor];
			} else {
				([_x] call _fnc_resolveSharedGroup) params ["_grpSeats", "_grpControls"];
				private _keptSeats = _grpSeats select {!(_x in _removeFullSeatsSet) && {!((format ["%1|%2", _x, NO_TEXTURE_SELECTION]) in _removePairSet)}};
				if (_keptSeats isNotEqualTo []) then {
					private _keptCtrls = if (_grpControls isEqualTo [] || {_grpControls isEqualTo ["__NO_CONTROLLER__"]}) then {
						_grpControls
					} else {
						private _c = _grpControls select {_x in _keptSeats};
						if (_c isEqualTo []) then {["__NO_CONTROLLER__"]} else {_c}
					};
					_rewriteSharedGroups pushBack [_keptSeats, _keptCtrls, _parsedCount];
					{
						_rewriteSharedSeatSet set [_x, true];
					} forEach _keptSeats;
				};
			};
		} else {
			if ([_x] call _fnc_isInvalidSharedTexEntry) then {
				diag_log format ["[CFM] Shared multi-seat monitor entry %1 only supports PiP (count or -1); ignoring on %2", _x, _monitor];
			} else {
				private _seatDesc = _x;
				private _texSel = NO_TEXTURE_SELECTION;
				private _hasExp = false;
				private _pipCount = 1;
				private _skipItem = false;
				if ([_x] call _fnc_isPairEntry) then {
					_seatDesc = _x select 0;
					([_x select 1] call _fnc_parsePairSecond) params ["", "_isTexSel", "_parsedTexSel", "_parsedCount"];
					if (!_isTexSel && {_parsedCount <= 0}) then {
						diag_log format ["[CFM] Monitor count 0 ignored for seat %1 on %2 (use ""#0"" for texture selection 0)", _seatDesc, _monitor];
						_skipItem = true;
					} else {
						_texSel = if (_isTexSel) then {_parsedTexSel} else {NO_TEXTURE_SELECTION};
						_pipCount = if (_isTexSel) then {1} else {_parsedCount};
						_hasExp = true;
					};
				};
				if !(_skipItem) then {
					{
						private _sk = _x;
						if (!(_sk in _removeFullSeatsSet) && {!((format ["%1|%2", _sk, _texSel]) in _removePairSet)}) then {
							private _effCount = if (_texSel < 0) then {
								_pipCount - (_removePipCountMap getOrDefault [_sk, 0])
							} else {
								1
							};
							if (_effCount > 0) then {
								private _arr = _rewriteMap getOrDefault [_sk, []];
								private _idx = _arr findIf {(_x select 0) == _texSel};
								if (_idx >= 0) then {
									if (_hasExp) then {
										(_arr select _idx) set [1, true];
										if (_texSel < 0) then {
											(_arr select _idx) set [2, _effCount];
										};
									};
								} else {
									_arr pushBack [_texSel, _hasExp, _effCount];
								};
								_rewriteMap set [_sk, _arr];
							};
						};
					} forEach ([_seatDesc] call _fnc_resolveSeatDesc);
				};
			};
		};
	} forEach _rwItems;
} forEach _rewriteBodies;

private _addItemsList = [];
{
	_x params ["_body", "_fromBrackets"];
	_addItemsList append ([_body, _fromBrackets] call _fnc_parseModifierItems);
} forEach _addBodies;
_addItemsList append _rawSeatItems;

private _addSpecs = [];
private _addSuppressBasePipSeats = createHashMap;
{
	if ([_x] call _fnc_isSharedGroupEntry) then {
		([_x select 1] call _fnc_parsePairSecond) params ["", "", "", "_parsedCount"];
		if (_parsedCount <= 0) then {
			diag_log format ["[CFM] Monitor count 0 ignored for shared entry %1 on %2 (use ""#0"" for texture selection 0)", _x, _monitor];
		} else {
			([_x] call _fnc_resolveSharedGroup) params ["_grpSeats", "_grpControls"];
			private _keptSeats = _grpSeats select {!(_x in _removeFullSeatsSet) && {!((format ["%1|%2", _x, NO_TEXTURE_SELECTION]) in _removePairSet)}};
			if (_keptSeats isNotEqualTo []) then {
				private _keptCtrls = if (_grpControls isEqualTo [] || {_grpControls isEqualTo ["__NO_CONTROLLER__"]}) then {
					_grpControls
				} else {
					private _c = _grpControls select {_x in _keptSeats};
					if (_c isEqualTo []) then {["__NO_CONTROLLER__"]} else {_c}
				};
				{
					_addSuppressBasePipSeats set [_x, true];
				} forEach _keptSeats;
				_addSpecs pushBack [NO_TEXTURE_SELECTION, _keptSeats joinString ", ", true, false, _keptSeats, _keptCtrls, "ADD", true, _parsedCount];
			};
		};
	} else {
		if ([_x] call _fnc_isInvalidSharedTexEntry) then {
			diag_log format ["[CFM] Shared multi-seat monitor entry %1 only supports PiP (count or -1); ignoring on %2", _x, _monitor];
		} else {
			private _seatDesc = _x;
			private _texSel = NO_TEXTURE_SELECTION;
			private _hasExp = false;
			private _pipCount = 1;
			private _skipItem = false;
			if ([_x] call _fnc_isPairEntry) then {
				_seatDesc = _x select 0;
				([_x select 1] call _fnc_parsePairSecond) params ["", "_isTexSel", "_parsedTexSel", "_parsedCount"];
				if (!_isTexSel && {_parsedCount <= 0}) then {
					diag_log format ["[CFM] Monitor count 0 ignored for seat %1 on %2 (use ""#0"" for texture selection 0)", _seatDesc, _monitor];
					_skipItem = true;
				} else {
					_texSel = if (_isTexSel) then {_parsedTexSel} else {NO_TEXTURE_SELECTION};
					_pipCount = if (_isTexSel) then {1} else {_parsedCount};
					_hasExp = true;
				};
			};
			if !(_skipItem) then {
				{
					private _sk = _x;
					if (!(_sk in _removeFullSeatsSet) && {!((format ["%1|%2", _sk, _texSel]) in _removePairSet)}) then {
						private _effCount = if (_texSel < 0) then {
							_pipCount - (_removePipCountMap getOrDefault [_sk, 0])
						} else {
							1
						};
						if (_effCount > 0) then {
							if (_hasExp) then {_addSuppressBasePipSeats set [_sk, true]};
							_addSpecs pushBack [_texSel, _sk, true, false, [_sk], [], "ADD", _hasExp, _effCount];
						};
					};
				} forEach ([_seatDesc] call _fnc_resolveSeatDesc);
			};
		};
	};
} forEach _addItemsList;

private _emittedRewritten = createHashMap;
{
	if (!(_x in _removeFullSeatsSet) && {!((format ["%1|%2", _x, NO_TEXTURE_SELECTION]) in _removePairSet)}) then {
		if (_x in _rewriteMap) then {
			private _rwSeat = _x;
			{
				_x params ["_rwTex", "_rwExp", ["_rwCount", 1]];
				_seatSpecsRaw pushBack [_rwTex, _rwSeat, true, false, [_rwSeat], [], "REWRITE", _rwExp, _rwCount];
			} forEach (_rewriteMap get _rwSeat);
			_emittedRewritten set [_rwSeat, true];
		} else {
			if (!(_x in _rewriteSharedSeatSet) && {!(_x in _addSuppressBasePipSeats)} && {(_removePipCountMap getOrDefault [_x, 0]) < 1}) then {
				_seatSpecsRaw pushBack [NO_TEXTURE_SELECTION, _x, true, false, [_x], [], _baseOpMode, false, 1];
			};
		};
	};
} forEach _baseKeys;

{
	_x params ["_grpSeats", "_grpControls", ["_grpCount", 1]];
	_seatSpecsRaw pushBack [NO_TEXTURE_SELECTION, _grpSeats joinString ", ", true, false, _grpSeats, _grpControls, "REWRITE", true, _grpCount];
} forEach _rewriteSharedGroups;

{
	private _rwSeat = _x;
	if (!(_rwSeat in _emittedRewritten) && {!(_rwSeat in _removeFullSeatsSet)}) then {
		{
			_x params ["_rwTex", "_rwExp", ["_rwCount", 1]];
			if !((format ["%1|%2", _rwSeat, _rwTex]) in _removePairSet) then {
				_seatSpecsRaw pushBack [_rwTex, _rwSeat, true, false, [_rwSeat], [], "REWRITE", _rwExp, _rwCount];
			};
		} forEach _y;
		_emittedRewritten set [_rwSeat, true];
	};
} forEach _rewriteMap;

{
	_x params ["_texSel", "_seatKey", "_isVeh", "_isHand", "_seatKeysArr", "_ctrlSeatKeys", "_opMode", "_hasExp", ["_pipCount", 1]];
	private _isSharedSpec = ((count _seatKeysArr) > 1) || {_ctrlSeatKeys isNotEqualTo []};
	if (_isSharedSpec) then {
		_seatSpecsRaw pushBack [_texSel, _seatKey, _isVeh, _isHand, _seatKeysArr, _ctrlSeatKeys, _opMode, _hasExp, _pipCount];
	} else {
		if (_seatKey in _rewriteMap) then {
			if !(_seatKey in _emittedRewritten) then {
				{
					_x params ["_rwTex", "_rwExp", ["_rwCount", 1]];
					_seatSpecsRaw pushBack [_rwTex, _seatKey, true, false, [_seatKey], [], "REWRITE", _rwExp, _rwCount];
				} forEach (_rewriteMap get _seatKey);
				_emittedRewritten set [_seatKey, true];
			};
		} else {
			if !(_seatKey in _rewriteSharedSeatSet) then {
				_seatSpecsRaw pushBack [_texSel, _seatKey, _isVeh, _isHand, _seatKeysArr, _ctrlSeatKeys, _opMode, _hasExp, _pipCount];
			};
		};
	};
} forEach _addSpecs;

// 4. Combine and prevent textureSelection conflicts & duplicate PiP seat entries
private _specs = [];
private _usedTexSels = createHashMap;
private _usedPipSeats = createHashMap;

// Reserve explicit seat-bound texture selections first so hybrid [seatKey, "#texSel"] wins if also listed in textureSelections
{
	_x params [
		"_texSel",
		"_seatKey",
		"_isVeh",
		"_isHand",
		["_seatKeysArr", []],
		["_ctrlSeatKeys", []],
		["_opMode", "ADD"],
		["_hasExp", false],
		["_pipCount", 1]
	];
	if (_seatKeysArr isEqualTo [] && {!(_seatKey isEqualTo "")}) then {
		_seatKeysArr = [_seatKey];
	};
	if (_texSel >= 0) then {
		if (_texSel in _usedTexSels) then {
			diag_log format ["[CFM] Duplicate monitor textureSelection %1 ignored for seat '%2' on %3", _texSel, _seatKey, _monitor];
		} else {
			_usedTexSels set [_texSel, true];
			_specs pushBack [_texSel, _seatKey, _isVeh, _isHand, _seatKeysArr, _ctrlSeatKeys, _opMode, _hasExp, 1];
		};
	} else {
		if (_seatKeysArr isNotEqualTo []) then {
			private _isSingleSeatSpec = ((count _seatKeysArr) == 1) && {_ctrlSeatKeys isEqualTo []};
			if (_isSingleSeatSpec && {(_seatKeysArr select 0) in _usedPipSeats}) then {
				if (_hasExp) then {
					private _sk = _seatKeysArr select 0;
					private _prevIdx = _usedPipSeats get _sk;
					if (_prevIdx isEqualType 0 && {_prevIdx >= 0} && {_prevIdx < (count _specs)}) then {
						private _prevSpec = _specs select _prevIdx;
						private _prevSeats = _prevSpec param [4, []];
						private _prevCtrls = _prevSpec param [5, []];
						if (((count _prevSeats) == 1) && {_prevCtrls isEqualTo []} && {(_prevSpec param [6, "ADD"]) isEqualTo _opMode}) then {
							_prevSpec set [7, true];
							_prevSpec set [8, _pipCount];
						};
					};
				};
			} else {
				private _freeSeats = _seatKeysArr select {!(_x in _usedPipSeats)};
				if (_freeSeats isNotEqualTo []) then {
					private _specIdx = count _specs;
					{
						_usedPipSeats set [_x, _specIdx];
					} forEach _freeSeats;
					private _finalSeatKey = _freeSeats joinString ", ";
					private _finalCtrlKeys = if (_ctrlSeatKeys isEqualTo [] || {_ctrlSeatKeys isEqualTo ["__NO_CONTROLLER__"]}) then {
						_ctrlSeatKeys
					} else {
						private _keptCtrls = _ctrlSeatKeys select {_x in _freeSeats};
						if (_keptCtrls isEqualTo []) then {["__NO_CONTROLLER__"]} else {_keptCtrls}
					};
					_specs pushBack [_texSel, _finalSeatKey, _isVeh, _isHand, _freeSeats, _finalCtrlKeys, _opMode, _hasExp, _pipCount];
				};
			};
		} else {
			if !(_seatKey in _usedPipSeats) then {
				_usedPipSeats set [_seatKey, count _specs];
				_specs pushBack [_texSel, _seatKey, _isVeh, _isHand, [], _ctrlSeatKeys, _opMode, _hasExp, _pipCount];
			};
		};
	};
} forEach _seatSpecsRaw;

private _texOnlySpecs = [];
{
	if !(_x in _usedTexSels) then {
		_usedTexSels set [_x, true];
		_texOnlySpecs pushBack [_x, "", false, false, [], [], "REWRITE", true, 1];
	} else {
		diag_log format ["[CFM] TextureSelection %1 already bound to a seat on %2; skipping duplicate", _x, _monitor];
	};
} forEach _texRewriteSels;

{
	if !(_x in _usedTexSels) then {
		_usedTexSels set [_x, true];
		_texOnlySpecs pushBack [_x, "", false, false, [], [], "ADD", true, 1];
	} else {
		diag_log format ["[CFM] TextureSelection %1 already bound to a seat on %2; skipping duplicate", _x, _monitor];
	};
} forEach _texAddSels;

private _texRemoveSpecs = _texRemoveSels apply {[_x, "", false, false, [], [], "REMOVE", true, 1]};

// Order: removals first (unbinds selections/seats before additions), then standalone texture monitors, then seat instances
private _orderedSpecs = _removeSpecs + _texRemoveSpecs + _texOnlySpecs + _specs;

if (_orderedSpecs isEqualTo []) then {
	if (_isEmptyKeys) then {
		if (_isVehSeatTablet) then {
			_orderedSpecs = [[NO_TEXTURE_SELECTION, "", true, false, [], [], "BASE_EMPTY", false, 1]];
		} else {
			_orderedSpecs = [[0, "", false, false, [], [], "BASE_EMPTY", true, 1]];
		};
	} else {
		if (_isVehSeatTablet && {!(_baseMode isEqualTo "")} && {_crewInfo isEqualTo []} && {_removeSpecs isEqualTo []} && {_texRemoveSpecs isEqualTo []} && {_texOnlySpecs isEqualTo []}) then {
			_orderedSpecs = [[NO_TEXTURE_SELECTION, "", true, false, [], [], _baseOpMode, false, 1]];
		};
	};
};

_orderedSpecs
