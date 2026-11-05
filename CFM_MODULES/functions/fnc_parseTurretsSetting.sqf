/*
	Function: _parseTurretsSetting
	Parses cameraNVGParams or cameraTIParams string for turrets.
	Supports Common, APPLY, SET, and Mixed grammar.
	Author: Gemini Argon
*/
private _parseTurretsSetting = {
	params [
		["_inputStr", "-1"],
		["_isTi", false],
		["_allTurrets", [-1]],
		["_isCameraTurret", false]
	];

	if !(_inputStr isEqualType "") then {
		_inputStr = str _inputStr;
	};
	_inputStr = trim _inputStr;
	if (_inputStr isEqualTo "") then {
		_inputStr = "-1";
	};

	// Вспомогательная функция снятия внешних кавычек (замена несуществующих startsWith/endsWith)
	private _fnc_stripQuotes = {
		params ["_str"];
		private _len = count _str;
		if (_len >= 2) then {
			private _first = _str select [0, 1];
			private _last = _str select [_len - 1, 1];
			if ((_first isEqualTo """" && {_last isEqualTo """"}) || {_first isEqualTo "'" && {_last isEqualTo "'"}}) then {
				_str = trim (_str select [1, _len - 2]);
			};
		};
		_str
	};

	// Проверка, является ли элемент инструкцией вида [_turretIdx, _value]
	private _fnc_isSetInstruction = {
		params ["_elem", "_forTi"];
		if (!(_elem isEqualType []) || {count _elem != 2}) exitWith {false};
		_elem params ["_a", "_b"];
		if !(_a isEqualType 0) exitWith {false};

		if (_b isEqualType [] || {_b isEqualType true} || {_b isEqualType ""}) exitWith {true};
		if (_b isEqualType 0 && {_b in [-1, -2]}) exitWith {true};
		if (!_forTi && {_b isEqualType 0 && {_b in [0, 1]}}) exitWith {true};

		false
	};

	// Нормализация одиночного значения
	private _fnc_parseVal = {
		params ["_val", "_forTi"];

		if (_val isEqualType "") exitWith {
			private _trimmed = [toLower (trim _val)] call _fnc_stripQuotes;

			if (_trimmed in ["", "-1", "def", "default"]) exitWith {-1};
			if (_forTi) then {
				if (_trimmed in ["-2", "[]", "false"]) exitWith {[]};
				if (_trimmed in ["true", "1"]) exitWith {[2, 7]};
				
				private _compiled = call compile _trimmed;
				if (!isNil "_compiled") then {
					if (_compiled isEqualType []) exitWith {
						if (_compiled isEqualTo [] || {_compiled isEqualTo [-2]}) exitWith {[]};
						if (_compiled isEqualTo [-1]) exitWith {-1};
						_compiled select {_x isEqualType 0 && {_x >= 0}}
					};
					if (_compiled isEqualType 0) exitWith {
						if (_compiled == -1) exitWith {-1};
						if (_compiled == -2) exitWith {[]};
						[_compiled]
					};
					-1
				} else {
					private _nums = (_trimmed splitString SPLIT_CHARACTERS) apply {parseNumber _x} select {_x >= 0};
					if (_nums isNotEqualTo []) then {_nums} else {-1}
				};
			} else {
				if (_trimmed in ["-2", "[]", "false", "0"]) exitWith {false};
				if (_trimmed in ["true", "1"]) exitWith {true};
				-1
			};
		};

		if (_val isEqualType true) exitWith {
			if (_forTi) then {
				if (_val) then {[2, 7]} else {[]}
			} else {
				_val
			}
		};

		if (_val isEqualType 0) exitWith {
			if (_forTi) then {
				if (_val == -1) exitWith {-1};
				if (_val == -2) exitWith {[]};
				[_val]
			} else {
				if (_val == -1) exitWith {-1};
				if (_val in [-2, 0]) exitWith {false};
				if (_val == 1) exitWith {true};
				-1
			}
		};

		if (_val isEqualType []) exitWith {
			if (_val isEqualTo [] || {_val isEqualTo [-2]} || {_val isEqualTo ["-2"]}) exitWith {
				if (_forTi) then {[]} else {false}
			};
			if (_val isEqualTo [-1] || {_val isEqualTo ["-1"]}) exitWith {-1};
			if (_forTi) then {
				private _nums = [];
				{
					if (_x isEqualType 0 && {_x >= 0}) then {
						_nums pushBack _x; // Исправлена опечатка _modes -> _nums
					} else {
						if (_x isEqualType "") then {
							private _trimmedX = trim _x;
							private _n = parseNumber _trimmedX;
							if (_trimmedX isNotEqualTo "" && {_n >= 0}) then {
								_nums pushBack _n;
							};
						};
					};
				} forEach _val;
				_nums
			} else {
				false
			}
		};

		-1
	};

	// Токенизация строки на глубине 0 с учётом скобок и кавычек (убрано дублирование кода)
	private _fnc_tokenize = {
		params ["_str"];
		private _tokens = [];
		private _curChars = [];
		private _depth = 0;
		private _inQuotes = false;
		private _quoteChar = "";

		{
			if (!_inQuotes && {_x isEqualTo """" || {_x isEqualTo "'"}}) then {
				_inQuotes = true;
				_quoteChar = _x;
				_curChars pushBack _x;
			} else {
				if (_inQuotes && {_x isEqualTo _quoteChar}) then {
					_inQuotes = false;
					_curChars pushBack _x;
				} else {
					if (!_inQuotes) then {
						if (_x isEqualTo "[") then {
							_depth = _depth + 1;
							_curChars pushBack _x;
						} else {
							if (_x isEqualTo "]") then {
								_depth = (_depth - 1) max 0;
								_curChars pushBack _x;
							} else {
								if (_depth == 0 && {_x isEqualTo "," || {_x isEqualTo ";"}}) then {
									private _tok = trim (_curChars joinString "");
									if (_tok isNotEqualTo "") then { _tokens pushBack _tok; };
									_curChars = [];
								} else {
									_curChars pushBack _x;
								};
							};
						};
					} else {
						_curChars pushBack _x;
					};
				};
			};
		} forEach (_str splitString "");

		private _lastTok = trim (_curChars joinString "");
		if (_lastTok isNotEqualTo "") then {
			_tokens pushBack _lastTok;
		};
		_tokens
	};

	private _rawTokens = [_inputStr] call _fnc_tokenize;

	// Проверка на обёртку во внешние скобки массива, например "[[...], [...]]"
	if (count _rawTokens == 1) then {
		private _single = _rawTokens select 0;
		private _len = count _single;
		if (_len >= 2 && {(_single select [0, 1]) isEqualTo "["} && {(_single select [_len - 1, 1]) isEqualTo "]"}) then {
			private _inner = trim (_single select [1, _len - 2]);
			private _compiledSingle = call compile _single;
			if (!isNil "_compiledSingle" && {_compiledSingle isEqualType []} && {_compiledSingle isNotEqualTo []}) then {
				if !([_compiledSingle, _isTi] call _fnc_isSetInstruction) then {
					private _isFlatModes = _isTi && {(_compiledSingle findIf {!(_x isEqualType 0) || {_x < 0}}) == -1};
					if (!_isFlatModes) then {
						private _innerTokens = [_inner] call _fnc_tokenize;
						if (
							count _innerTokens > 1 ||
							{count _innerTokens == 1 && {
								private _comp = call compile (_innerTokens select 0);
								!isNil "_comp" && {[_comp, _isTi] call _fnc_isSetInstruction}
							}}
						) then {
							_rawTokens = _innerTokens;
						};
					};
				};
			};
		};
	};

	// Проверка на список чисел без скобок для TI (например "2, 6")
	if (_isTi && {count _rawTokens > 1}) then {
		private _allPositiveNumbers = true;
		private _compiledNums = [];
		{
			private _comp = call compile _x;
			if (isNil "_comp" || {!(_comp isEqualType 0)} || {_comp < 0}) exitWith {
				_allPositiveNumbers = false;
			};
			_compiledNums pushBack _comp;
		} forEach _rawTokens;

		if (_allPositiveNumbers) then {
			_rawTokens = [str _compiledNums];
		};
	};

	// Инициализация карты результатов значениями по умолчанию (-1)
	private _resultMap = createHashMap;
	{
		_resultMap set [_x, -1];
	} forEach _allTurrets;

	if (_rawTokens isEqualTo []) exitWith {_resultMap};

	if (_isCameraTurret || {count _rawTokens == 1}) then {
		private _firstTokStr = _rawTokens select 0;
		private _tokVal = call compile _firstTokStr;
		if (isNil "_tokVal") then { _tokVal = _firstTokStr; };

		if ([_tokVal, _isTi] call _fnc_isSetInstruction) then {
			_tokVal params ["_tIdx", "_setting"];
			private _parsed = [_setting, _isTi] call _fnc_parseVal;
			_resultMap set [TURRET_INDEX(_tIdx), _parsed];
		} else {
			private _parsed = [_tokVal, _isTi] call _fnc_parseVal;
			{
				_resultMap set [_x, _parsed];
			} forEach _allTurrets;
		};
	} else {
		{
			private _tokStr = _x;
			private _tokVal = call compile _tokStr;
			if (isNil "_tokVal") then { _tokVal = _tokStr; };

			if ([_tokVal, _isTi] call _fnc_isSetInstruction) then {
				_tokVal params ["_tIdx", "_setting"];
				private _parsed = [_setting, _isTi] call _fnc_parseVal;
				_resultMap set [TURRET_INDEX(_tIdx), _parsed];
			} else {
				if (_forEachIndex < count _allTurrets) then {
					private _tIdx = _allTurrets select _forEachIndex;
					private _parsed = [_tokVal, _isTi] call _fnc_parseVal;
					_resultMap set [TURRET_INDEX(_tIdx), _parsed];
				};
			};
		} forEach _rawTokens;
	};

	_resultMap
};