/*
    Function: CFM_fnc_parseMonitorSelections
    Author: Vazar
    Description: Parses textureSelections and seatKeys into deterministic monitor instance specs:
                 [[_texSel, _seatKey, _isVehSeatTablet, _isHandTablet], ...]
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
	[[NO_TEXTURE_SELECTION, "", false, true]]
};

// Split comma-separated tokens outside [] brackets and quotes
private _fnc_splitTopLevel = {
	params ["_input"];
	private _trimmed = trim _input;
	if (_trimmed isEqualTo "") exitWith {[]};
	private _tokens = [];
	private _cur = "";
	private _depth = 0;
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
					if (_ch in ["[", "("]) then {_depth = _depth + 1};
					if (_ch in ["]", ")"] && {_depth > 0}) then {_depth = _depth - 1};
					if (_ch isEqualTo "," && {_depth == 0}) then {
						private _tok = trim _cur;
						if !(_tok isEqualTo "") then {_tokens pushBack _tok};
						_cur = "";
						_handled = true;
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
	private _normalized = if ((_s find "'") >= 0 && {(_s find """") < 0}) then {
		(_s splitString "'") joinString """"
	} else {_s};
	private _arr = parseSimpleArray _normalized;
	if (!isNil "_arr" && {_arr isEqualType []}) exitWith {_arr};

	// Fallback for unquoted [seatKey, texSel] pairs such as [driver, 0] or [turret_[2], 0]
	private _len = count _s;
	if (_len >= 2 && {(_s select [0, 1]) isEqualTo "["} && {(_s select [_len - 1, 1]) isEqualTo "]"}) then {
		private _parts = [_s select [1, _len - 2]] call _fnc_splitTopLevel;
		if ((count _parts) == 2 && {(_parts select 1) regexMatch "^-?[0-9]+$"}) exitWith {
			[_parts select 0, parseNumber (_parts select 1)]
		};
	};
	nil
};

// 1. Parse textureSelections -> array of non-negative integers
private _texSels = [];
if (_textureSelections isEqualType 0) then {
	if (_textureSelections >= 0) then {_texSels pushBack (floor _textureSelections)};
} else {
	if (_textureSelections isEqualType []) then {
		{
			if (_x isEqualType 0 && {_x >= 0}) then {_texSels pushBackUnique (floor _x)};
		} forEach _textureSelections;
	} else {
		if (_textureSelections isEqualType "") then {
			private _s = trim _textureSelections;
			if !(_s isEqualTo "") then {
				if ((_s select [0, 1]) isEqualTo "[") then {
					private _arr = [_s] call _fnc_tryParseArray;
					if (_arr isEqualType []) then {
						{
							if (_x isEqualType 0 && {_x >= 0}) then {_texSels pushBackUnique (floor _x)};
						} forEach _arr;
					};
				} else {
					private _tokens = [_s] call _fnc_splitTopLevel;
					{
						if ((_x regexMatch "^-?[0-9]+$")) then {
							private _num = parseNumber _x;
							if (_num >= 0) then {_texSels pushBackUnique (floor _num)};
						};
					} forEach _tokens;
				};
			};
		};
	};
};

// 2. Parse seatKeys -> raw entries
private _fnc_isPairEntry = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {(count _arr) != 2}) exitWith {false};
	private _first = _arr select 0;
	private _second = _arr select 1;
	!(_first isEqualType 0) && {_second isEqualType 0} && {_second >= -1}
};

private _fnc_isSingleTurretOrDesc = {
	params ["_arr"];
	if (!(_arr isEqualType []) || {_arr isEqualTo []}) exitWith {false};
	if ([_arr] call _fnc_isPairEntry) exitWith {true};
	// [0], [0, 1], [-1] -> numeric turret path
	if (({_x isEqualType 0} count _arr) == (count _arr)) exitWith {true};
	// ["turret", [0]] or ["cargo", [..]] style single descriptor
	((count _arr) == 2) && {(_arr select 0) isEqualType ""} && {toLower (_arr select 0) isEqualTo "turret"} && {(_arr select 1) isEqualType []}
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
				if !(_tok isEqualTo "") then {_items pushBack _tok};
			};
		};
	} forEach _tokens;
	_items
};

private _fnc_parseRewriteItems = {
	params ["_body"];
	private _pairCandidate = [format ["[%1]", _body]] call _fnc_tryParseArray;
	if (!isNil "_pairCandidate" && {_pairCandidate isEqualType []} && {[_pairCandidate] call _fnc_isPairEntry}) exitWith {
		[_pairCandidate]
	};
	[_body] call _fnc_parseListString
};

private _useModifier = false;
private _baseMode = ""; // "", "DEFAULT", "ALL"
private _addBodies = [];
private _removeBodies = [];
private _rewriteBodies = [];
private _rawSeatItems = [];

if (_seatKeys isEqualType "") then {
	private _s = trim _seatKeys;
	if (_s isEqualTo "") then {
		if (_isVehSeatTablet) then {
			_useModifier = true;
			_baseMode = "DEFAULT";
		};
	} else {
		private _wsChars = [" ", toString [9], toString [10], toString [13]];
		private _skipChars = _wsChars + [","];
		private _sLen = count _s;
		private _pos = 0;
		private _parsedOk = true;
		private _sawModifierToken = false;

		while {_pos < _sLen && {_parsedOk}} do {
			while {_pos < _sLen && {(_s select [_pos, 1]) in _skipChars}} do {
				_pos = _pos + 1;
			};
			if (_pos >= _sLen) exitWith {};

			private _ch = _s select [_pos, 1];
			private _rest = _s select [_pos];

			if ((toLower (_rest select [0, 3])) isEqualTo "all" && {(_pos + 3 >= _sLen) || {!((_s select [_pos + 3, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
				_baseMode = "ALL";
				_sawModifierToken = true;
				_pos = _pos + 3;
				continue;
			};
			if ((toLower (_rest select [0, 7])) isEqualTo "default" && {(_pos + 7 >= _sLen) || {!((_s select [_pos + 7, 1]) regexMatch "[A-Za-z0-9_]")}}) then {
				if (_baseMode isEqualTo "") then {_baseMode = "DEFAULT"};
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
					private _depth = 0;
					private _inDQ = false;
					private _inSQ = false;
					private _endIdx = -1;
					for "_k" from _j to (_sLen - 1) do {
						private _c = _s select [_k, 1];
						if (_c isEqualTo """" && {!_inSQ}) then {
							_inDQ = !_inDQ;
						} else {
							if (_c isEqualTo "'" && {!_inDQ}) then {
								_inSQ = !_inSQ;
							} else {
								if (!_inDQ && {!_inSQ}) then {
									if (_c isEqualTo "[") then {_depth = _depth + 1};
									if (_c isEqualTo "]") then {
										_depth = _depth - 1;
										if (_depth == 0) exitWith {_endIdx = _k};
									};
								};
							};
						};
					};
					if (_endIdx > _j) then {
						private _inner = _s select [_j + 1, _endIdx - _j - 1];
						switch (_ch) do {
							case "+": { _addBodies pushBack _inner; };
							case "-": { _removeBodies pushBack _inner; };
							case "!": { _rewriteBodies pushBack _inner; };
						};
						_sawModifierToken = true;
						_pos = _endIdx + 1;
						continue;
					};
				};
			};

			_parsedOk = false;
		};

		if (_parsedOk && {_sawModifierToken}) then {
			_useModifier = true;
			if (_baseMode isEqualTo "") then {
				_baseMode = "DEFAULT";
			};
		} else {
			_addBodies = [];
			_removeBodies = [];
			_rewriteBodies = [];
			_rawSeatItems = [_s] call _fnc_parseListString;
		};
	};
} else {
	if (_seatKeys isEqualType []) then {
		if (_seatKeys isEqualTo []) then {
			if (_isVehSeatTablet) then {
				_useModifier = true;
				_baseMode = "DEFAULT";
			};
		} else {
			if ((count _seatKeys == 1) && {(_seatKeys select 0) isEqualType ""} && {(toLower trim (_seatKeys select 0)) in ["all", "default"]}) then {
				_useModifier = true;
				_baseMode = ["DEFAULT", "ALL"] select ((toLower trim (_seatKeys select 0)) isEqualTo "all");
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

// 3. Build canonical seat descriptors from fullCrew
private _allCrew = if (IS_OBJ(_monitor)) then {fullCrew [_monitor, "", true]} else {[]};
private _crewInfo = _allCrew apply {
	private _key = [_x] call CFM_fnc_getCrewSeatKey;
	[_key, toLower (_x param [1, ""]), _x param [2, -1], _x param [3, []]]
};

private _fnc_resolveSeatDesc = {
	params ["_desc"];
	private _keys = [];
	{
		_x params ["_key", "_role", "_cargoIdx", "_turretPath"];
		if !(_key isEqualTo "") then {
			private _matched = false;
			if (_desc isEqualType "") then {
				private _d = toLower (trim _desc);
				_matched = (_d isEqualTo (toLower _key)) || {_d isEqualTo _role};
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

	if (_keys isEqualTo [] && {_crewInfo isEqualTo []} && {_desc isEqualType ""}) then {
		private _d = trim _desc;
		if !(_d isEqualTo "") then {_keys pushBack _d};
	};
	_keys
};

private _seatSpecsRaw = [];
if (_useModifier) then {
	private _baseKeys = [];
	{
		_x params ["_key", "_role"];
		if !(_key isEqualTo "") then {
			if (_baseMode isEqualTo "ALL" || {_role in ["driver", "gunner", "commander"]}) then {
				_baseKeys pushBackUnique _key;
			};
		};
	} forEach _crewInfo;

	private _removeKeysSet = createHashMap;
	{
		private _remItems = [_x] call _fnc_parseListString;
		{
			private _desc = if ([_x] call _fnc_isPairEntry) then {_x select 0} else {_x};
			{
				_removeKeysSet set [_x, true];
			} forEach ([_desc] call _fnc_resolveSeatDesc);
		} forEach _remItems;
	} forEach _removeBodies;

	private _rewriteMap = createHashMap;
	{
		private _rwItems = [_x] call _fnc_parseRewriteItems;
		{
			private _seatDesc = _x;
			private _texSel = NO_TEXTURE_SELECTION;
			if ([_x] call _fnc_isPairEntry) then {
				_seatDesc = _x select 0;
				_texSel = floor (_x select 1);
				if (_texSel < 0) then {_texSel = NO_TEXTURE_SELECTION};
			};
			{
				private _arr = _rewriteMap getOrDefault [_x, []];
				_arr pushBackUnique _texSel;
				_rewriteMap set [_x, _arr];
			} forEach ([_seatDesc] call _fnc_resolveSeatDesc);
		} forEach _rwItems;
	} forEach _rewriteBodies;

	private _addSpecs = [];
	private _addTexBoundSeats = createHashMap;
	{
		private _addItems = [_x] call _fnc_parseListString;
		{
			private _seatDesc = _x;
			private _texSel = NO_TEXTURE_SELECTION;
			if ([_x] call _fnc_isPairEntry) then {
				_seatDesc = _x select 0;
				_texSel = floor (_x select 1);
				if (_texSel < 0) then {_texSel = NO_TEXTURE_SELECTION};
			};
			{
				if (_texSel >= 0) then {_addTexBoundSeats set [_x, true]};
				_addSpecs pushBack [_texSel, _x, true, false];
			} forEach ([_seatDesc] call _fnc_resolveSeatDesc);
		} forEach _addItems;
	} forEach _addBodies;

	private _emittedRewritten = createHashMap;
	{
		if !(_x in _removeKeysSet) then {
			if (_x in _rewriteMap) then {
				private _rwSeat = _x;
				{
					_seatSpecsRaw pushBack [_x, _rwSeat, true, false];
				} forEach (_rewriteMap get _rwSeat);
				_emittedRewritten set [_rwSeat, true];
			} else {
				if !(_x in _addTexBoundSeats) then {
					_seatSpecsRaw pushBack [NO_TEXTURE_SELECTION, _x, true, false];
				};
			};
		};
	} forEach _baseKeys;

	{
		_x params ["_texSel", "_seatKey", "_isVeh", "_isHand"];
		if (_seatKey in _rewriteMap) then {
			if !(_seatKey in _emittedRewritten) then {
				{
					_seatSpecsRaw pushBack [_x, _seatKey, true, false];
				} forEach (_rewriteMap get _seatKey);
				_emittedRewritten set [_seatKey, true];
			};
		} else {
			_seatSpecsRaw pushBack [_texSel, _seatKey, _isVeh, _isHand];
		};
	} forEach _addSpecs;

	{
		private _rwSeat = _x;
		if (!(_rwSeat in _emittedRewritten) && {!(_rwSeat in _removeKeysSet)}) then {
			{
				_seatSpecsRaw pushBack [_x, _rwSeat, true, false];
			} forEach _y;
		};
	} forEach _rewriteMap;
} else {
	{
		private _item = _x;
		private _seatDesc = _item;
		private _texSel = NO_TEXTURE_SELECTION;
		if ([_item] call _fnc_isPairEntry) then {
			_seatDesc = _item select 0;
			_texSel = floor (_item select 1);
			if (_texSel < 0) then {_texSel = NO_TEXTURE_SELECTION};
		};
		private _resolvedKeys = [_seatDesc] call _fnc_resolveSeatDesc;
		{
			_seatSpecsRaw pushBack [_texSel, _x, true, false];
		} forEach _resolvedKeys;
	} forEach _rawSeatItems;
};

// 4. Combine and prevent textureSelection conflicts & duplicate PiP seat entries
private _specs = [];
private _usedTexSels = createHashMap;
private _usedPipSeats = createHashMap;

// Reserve explicit seat-bound texture selections first so hybrid [seatKey, texSel] wins if also listed in textureSelections
{
	_x params ["_texSel", "_seatKey", "_isVeh", "_isHand"];
	if (_texSel >= 0) then {
		if (_texSel in _usedTexSels) then {
			diag_log format ["[CFM] Duplicate monitor textureSelection %1 ignored for seat '%2' on %3", _texSel, _seatKey, _monitor];
		} else {
			_usedTexSels set [_texSel, true];
			_specs pushBack [_texSel, _seatKey, _isVeh, _isHand];
		};
	} else {
		if !(_seatKey in _usedPipSeats) then {
			_usedPipSeats set [_seatKey, true];
			_specs pushBack [_texSel, _seatKey, _isVeh, _isHand];
		};
	};
} forEach _seatSpecsRaw;

private _texOnlySpecs = [];
{
	if !(_x in _usedTexSels) then {
		_usedTexSels set [_x, true];
		_texOnlySpecs pushBack [_x, "", false, false];
	} else {
		diag_log format ["[CFM] TextureSelection %1 already bound to a seat on %2; skipping duplicate", _x, _monitor];
	};
} forEach _texSels;

// Order: standalone texture monitors first, then seat instances
private _orderedSpecs = _texOnlySpecs + _specs;

private _hadSeatConstraints = (_rawSeatItems isNotEqualTo []) || {_addBodies isNotEqualTo []} || {_removeBodies isNotEqualTo []} || {_rewriteBodies isNotEqualTo []};
if (_orderedSpecs isEqualTo []) then {
	if (_isVehSeatTablet) then {
		if (!_hadSeatConstraints && {_crewInfo isEqualTo []}) then {
			_orderedSpecs = [[NO_TEXTURE_SELECTION, "", true, false]];
		};
	} else {
		if (!_hadSeatConstraints && {_texSels isEqualTo []}) then {
			_orderedSpecs = [[0, "", false, false]];
		};
	};
};

_orderedSpecs
