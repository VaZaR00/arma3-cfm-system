/*
    Function: CFM_fnc_parseScreenResolution
    Author: Vazar
    Description:
        Parses screen resolution parameter into [width, height] pixel array.
        Supported formats:
            - "1:1", "4:3", "16:9" (w:h aspect ratio with default width 512)
            - "1:1 500", "4:3 800" (w:h aspect ratio and explicit width in pixels)
            - "700x500" (explicit width x height in pixels)
            - [700, 500] or ["4:3", 500] (array format)
            - 500 or "500" (square width x height)
*/

#include "defines.hpp"

params [["_input", ""]];

if (isNil "_input") exitWith {[]};

if (_input isEqualType 0) exitWith {
    if (_input <= 0) then {[]} else {[_input, _input]}
};

if (_input isEqualType []) exitWith {
    if (count _input < 2) exitWith {[]};
    private _first = _input select 0;
    private _second = _input select 1;
    if ((_first isEqualType "") && {(_second isEqualType 0)} && {_second > 0}) exitWith {
        [format ["%1 %2", _first, _second]] call CFM_fnc_parseScreenResolution
    };
    if ((_first isEqualType 0) && {(_second isEqualType 0)} && {_first > 0} && {_second > 0}) exitWith {
        [_first, _second]
    };
    []
};

if !(_input isEqualType "") exitWith {[]};

private _str = trim _input;
if ((_str isEqualTo "") || {(toLower _str) in ["default", "-1"]}) exitWith {[]};

if ("[" in _str) exitWith {
    private _arr = parseSimpleArray _str;
    if (isNil "_arr" || {!(_arr isEqualType [])}) exitWith {[]};
    [_arr] call CFM_fnc_parseScreenResolution
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
    [_width, _height]
};

// Format "WxH" (e.g. "700x500", "700X500", "700*500", or "700 500")
private _dimParts = (_str splitString "xXхХ* ,;\t") select {_x isNotEqualTo ""};
if (count _dimParts >= 2) exitWith {
    private _w = parseNumber (_dimParts select 0);
    private _h = parseNumber (_dimParts select 1);
    if ((_w <= 0) || {_h <= 0}) exitWith {[]};
    [_w, _h]
};

if (count _dimParts == 1) exitWith {
    private _w = parseNumber (_dimParts select 0);
    if (_w <= 0) exitWith {[]};
    [_w, _w]
};

[]
