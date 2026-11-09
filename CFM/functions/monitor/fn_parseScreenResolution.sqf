/*
    Function: CFM_fnc_parseScreenResolution
    Author: Vazar
    Description:
        Parses screen resolution parameter into [width, height, [scaleX, scaleY]] array.
        Supported formats:
            - "1:1", "4:3", "16:9" (w:h aspect ratio with default width 512)
            - "1:1 500", "4:3 800" (w:h aspect ratio and explicit width in pixels)
            - "700x500" (explicit width x height in pixels)
            - "{0.8, 0.8}", "16:9 {0.8, 0.8}", "700x500 {-0.8, -0.8}" (optional {scaleX, scaleY} viewport scaling & anchor:
                +X = from left, -X = from right; +Y = from top, -Y = from bottom)
            - [700, 500], [700, 500, [0.8, 0.8]], or ["4:3", 500, [0.8, 0.8]] (array format)
            - 500 or "500" (square width x height)
*/

#include "defines.hpp"

params [["_input", ""], ["_monitor", objNull]];

if (isNil "_input") exitWith {[]};

if (_input isEqualType 0) exitWith {
	if (_input <= 0) then {[]} else {[_input, _input, +DEFAULT_UI_SCALE]}
};

if (_input isEqualType []) exitWith {
	if (count _input < 2) exitWith {[]};
	private _first = _input select 0;
	private _second = _input select 1;
	private _third = _input param [2, DEFAULT_UI_SCALE];
	private _scaleArr = if ((_third isEqualType []) && {count _third >= 2} && {(_third select 0) isEqualType 0} && {(_third select 1) isEqualType 0} && {(_third select 0) != 0} && {(_third select 1) != 0}) then {
		[_third select 0, _third select 1]
	} else {
		+DEFAULT_UI_SCALE
	};

	if ((_first isEqualType "") && {(_second isEqualType []) && {count _second >= 2}}) exitWith {
		private _parsed = [_first, _monitor] call CFM_fnc_parseScreenResolution;
		if (_parsed isEqualTo []) exitWith {[]};
		private _sx = _second param [0, 1];
		private _sy = _second param [1, 1];
		if ((_sx isEqualType 0) && {_sy isEqualType 0} && {_sx != 0} && {_sy != 0}) then {
			_parsed set [2, [_sx, _sy]];
		};
		_parsed
	};
	if ((_first isEqualType "") && {(_second isEqualType 0)} && {_second > 0}) exitWith {
		private _parsed = [format ["%1 %2", _first, _second], _monitor] call CFM_fnc_parseScreenResolution;
		if (_parsed isEqualTo []) exitWith {[]};
		_parsed set [2, _scaleArr];
		_parsed
	};
	if ((_first isEqualType 0) && {(_second isEqualType 0)} && {_first > 0} && {_second > 0}) exitWith {
		[_first, _second, _scaleArr]
	};
	[]
};

if !(_input isEqualType "") exitWith {[]};

private _str = trim _input;
if ((_str isEqualTo "") || {(toLower _str) in ["default", "-1"]}) exitWith {[]};

// Parse optional "{scaleX, scaleY}" block if present
private _scaleArr = +DEFAULT_UI_SCALE;
private _hasScaleBlock = false;
private _braceStart = _str find "{";
private _braceEnd = _str find "}";
if (_braceStart >= 0 && {_braceEnd > _braceStart}) then {
	private _braceContent = _str select [_braceStart + 1, _braceEnd - _braceStart - 1];
	private _scaleParts = (_braceContent splitString " ,;\t") select {_x isNotEqualTo ""};
	if (count _scaleParts >= 2) then {
		private _sx = parseNumber (_scaleParts select 0);
		private _sy = parseNumber (_scaleParts select 1);
		if (_sx != 0 && {_sy != 0}) then {
			_scaleArr = [_sx, _sy];
			_hasScaleBlock = true;
		};
	} else {
		if (count _scaleParts == 1) then {
			private _s = parseNumber (_scaleParts select 0);
			if (_s != 0) then {
				_scaleArr = [_s, _s];
				_hasScaleBlock = true;
			};
		};
	};
	_str = trim ((_str select [0, _braceStart]) + " " + (_str select [_braceEnd + 1]));
};

if (_str isEqualTo "") exitWith {
	if (!_hasScaleBlock) exitWith {[]};
	private _baseRes = if (IS_OBJ(_monitor)) then {
		[_monitor] call CFM_fnc_getDefaultScreenResolution
	} else {
		+DEFAULT_SCREEN_RESOLUTION
	};
	[_baseRes param [0, DEFAULT_UI_SIZE_W], _baseRes param [1, DEFAULT_UI_SIZE_H], _scaleArr]
};

if ("[" in _str) exitWith {
	private _arr = parseSimpleArray _str;
	if (isNil "_arr" || {!(_arr isEqualType [])}) exitWith {[]};
	private _parsed = [_arr, _monitor] call CFM_fnc_parseScreenResolution;
	if (_parsed isNotEqualTo [] && {_hasScaleBlock}) then {
		_parsed set [2, _scaleArr];
	};
	_parsed
};

// Format "w:h" or "w:h width" (e.g. "1:1", "4:3", "1:1 500")
if (":" in _str) exitWith {
	private _tokens = (_str splitString " ,;\t") select {_x isNotEqualTo ""};
	if (_tokens isEqualTo []) exitWith {[]};
	private _ratioParts = (_tokens select 0) splitString ":";
	if (count _ratioParts < 2) exitWith {[]};

	private _ratioW = parseNumber (_ratioParts select 0);
	private _ratioH = parseNumber (_ratioParts select 1);
	if ((_ratioW <= 0) || {_ratioH <= 0}) exitWith {[]};

	private _width = if (count _tokens >= 2) then {
		parseNumber (_tokens select 1)
	} else {
		missionNamespace getVariable ["CFM_uiDefaultWidth", DEFAULT_UI_SIZE_W]
	};
	if (_width <= 0) then {
		_width = missionNamespace getVariable ["CFM_uiDefaultWidth", DEFAULT_UI_SIZE_W];
	};

	private _height = (round (_width * (_ratioH / _ratioW))) max 1;
	[_width, _height, _scaleArr]
};

// Format "WxH" (e.g. "700x500", "700X500", "700*500", or "700 500")
private _dimParts = (_str splitString "xXхХ* ,;\t") select {_x isNotEqualTo ""};
if (count _dimParts >= 2) exitWith {
	private _w = parseNumber (_dimParts select 0);
	private _h = parseNumber (_dimParts select 1);
	if ((_w <= 0) || {_h <= 0}) exitWith {[]};
	[_w, _h, _scaleArr]
};

if (count _dimParts == 1) exitWith {
	private _w = parseNumber (_dimParts select 0);
	if (_w <= 0) exitWith {[]};
	[_w, _w, _scaleArr]
};

[]
