/*
    Function: CFM_fnc_parseControlFormula
    Author: Vazar
    Description:
        Parses a raw control parameter formula string or number from config
        (replacing (call {comment "W"; <arg>}), (call {comment "H"; <arg>}), etc.
        with runtime calls using _res) and compiles it into executable CODE.
*/

#include "defines.hpp"

params [["_rawFormula", 0]];

if (_rawFormula isEqualType 0) exitWith {
	compile (str _rawFormula)
};

if (!(_rawFormula isEqualType "") || {_rawFormula isEqualTo ""}) exitWith {
	{0}
};

private _str = _rawFormula;
private _markers = [
	["PW", "CFM_fnc_pixelW"],
	["PH", "CFM_fnc_pixelH"],
	["W", "CFM_fnc_width"],
	["H", "CFM_fnc_height"],
	["X", "CFM_fnc_posX"],
	["Y", "CFM_fnc_posY"]
];

{
	_x params ["_tag", "_fncName"];
	private _prefixes = [
		format ['(call {comment "%1";', _tag],
		format ['(call {comment ""%1"";', _tag],
		format ["(call {comment '%1';", _tag]
	];
	{
		private _prefix = _x;
		private _prefixLen = count _prefix;
		private _idx = _str find _prefix;
		while {_idx >= 0} do {
			private _before = _str select [0, _idx];
			private _rest = _str select [_idx + _prefixLen];
			private _closeIdx = _rest find "})";
			if (_closeIdx < 0) exitWith {};
			private _argStr = trim (_rest select [0, _closeIdx]);
			if (_argStr isEqualTo "") then {_argStr = "1"};
			private _after = _rest select [_closeIdx + 2];
			_str = format ["%1([%2, _res] call %3)%4", _before, _argStr, _fncName, _after];
			_idx = _str find _prefix;
		};
	} forEach _prefixes;
} forEach _markers;

compile _str
