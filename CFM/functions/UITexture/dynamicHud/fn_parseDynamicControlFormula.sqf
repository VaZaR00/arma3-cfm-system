/*
    Function: CFM_fnc_parseDynamicControlFormula
    Author: Vazar & Gemini
    Description:
        Compiles a control coordinate or font-size config property (x, y, w, h, size, sizeEx)
        from either CFM marker formulas, vanilla/modded Arma 3 expressions (safeZone*, pixelW/H,
        pixelGrid*, getResolution), or numeric constants into a fast evaluator tuple
        [scalarOrCode, isCfmMarker].
    Parameters:
        0: _propCfg [Config] - Config entry of the property (x, y, w, h, size, sizeEx).
    Returns:
        [Array] - [scalarNumber | compiledCode, isCfmMarker], or [] if property is absent.
*/

#include "defines.hpp"

params [["_propCfg", configNull, [configNull]]];

if (isNull _propCfg) exitWith {[]};
if (isNumber _propCfg) exitWith {[getNumber _propCfg, false]};
if !(isText _propCfg) exitWith {[]};

private _expr = trim (getText _propCfg);
if (_expr isEqualTo "") exitWith {[0, false]};

// Native CFM marker formula: (call {comment "W"; ...})
if ((_expr find "(call {comment ") >= 0) exitWith {
	private _cfmCode = [_expr] call CFM_fnc_parseControlFormula;
	[_cfmCode, true]
};

// Pure numeric literal stored as string
if (_expr regexMatch "^[+-]?[0-9]+(?:\.[0-9]+)?$/") exitWith {
	[parseNumber _expr, false]
};

// Rewrite global UI grid/screen tokens into virtual monitor-scoped variables
private _rewritten = _expr;
{
	_x params ["_pattern", "_replacement"];
	_rewritten = _rewritten regexReplace [_pattern, _replacement];
} forEach [
	["\bsafeZoneXAbs\b/gio", "_vSZX"],
	["\bsafeZoneWAbs\b/gio", "_vSZW"],
	["\bsafeZoneX\b/gio", "_vSZX"],
	["\bsafeZoneY\b/gio", "_vSZY"],
	["\bsafeZoneW\b/gio", "_vSZW"],
	["\bsafeZoneH\b/gio", "_vSZH"],
	["\bpixelGridNoUIScale\b/gio", "_vPGrid"],
	["\bpixelGridBase\b/gio", "_vPGrid"],
	["\bpixelGrid\b/gio", "_vPGrid"],
	["\bpixelW\b/gio", "_vPW"],
	["\bpixelH\b/gio", "_vPH"],
	["\bgetResolution\b/gio", "_vGetRes"]
];

private _testOk = false;
private _code = {};
isNil {
	private _vSZX = -0.1667;
	private _vSZY = 0;
	private _vSZW = 1.3333;
	private _vSZH = 1;
	private _vPGrid = 12;
	private _vPW = 1.3333 / 1920;
	private _vPH = 1 / 1080;
	private _vGetRes = [1920, 1080, 1920, 1080, 1.7778, 0.7, 0.75, 1.3333, false, 1];
	private _res = DEFAULT_SCREEN_RESOLUTION;
	_code = compile _rewritten;
	private _testVal = call _code;
	if (!isNil "_testVal" && {_testVal isEqualType 0} && {finite _testVal}) then {
		_testOk = true;
	};
};

if (!_testOk) exitWith {[0, false]};

[_code, false]
