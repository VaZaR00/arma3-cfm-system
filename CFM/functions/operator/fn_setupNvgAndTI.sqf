/*
	Function: CFM_fnc_setupNvgAndTI
	Author: Vazar & Gemini Argon
	Description: Sets up NVG and TI modes for a specific turret and updates the operator's state.
*/

#include "defines.hpp"

params [
	["_operator", objNull],
	["_turretIdx", -1],
	["_nvgParam", -1],
	["_tiParam", -1]
];

_turretIdx = TURRET_INDEX(_turretIdx);

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

private _finalNvg = false;
private _isNvgDefault = false;

call {
	if (_nvgParam isEqualType true) exitWith {
		_finalNvg = _nvgParam;
	};
	if (_nvgParam isEqualType 0) exitWith {
	if (_nvgParam == -1) exitWith { _isNvgDefault = true; };
	if (_nvgParam in [-2, 0]) exitWith { _finalNvg = false; };
	if (_nvgParam == 1) exitWith { _finalNvg = true; };
		_isNvgDefault = true;
	};
	if (_nvgParam isEqualType "") exitWith {
	private _s = [toLower (trim _nvgParam)] call _fnc_stripQuotes;
	if (_s in ["", "-1", "def", "default"]) exitWith { _isNvgDefault = true; };
	if (_s in ["-2", "[]", "false", "0"]) exitWith { _finalNvg = false; };
	if (_s in ["true", "1"]) exitWith { _finalNvg = true; };
		_isNvgDefault = true;
	};
	if (_nvgParam isEqualType [] && {_nvgParam isEqualTo [] || {_nvgParam isEqualTo [-2]}}) exitWith {
		_finalNvg = false;
	};
	_isNvgDefault = true;
};

private _finalTi = [];
private _isTiDefault = false;

call {
	if (_tiParam isEqualType true) exitWith {
		_finalTi = if (_tiParam) then {[2, 7]} else {[]};
	};
	if (_tiParam isEqualType 0) exitWith {
	if (_tiParam == -1) exitWith { _isTiDefault = true; };
	if (_tiParam == -2) exitWith { _finalTi = []; };
		_finalTi = [_tiParam];
	};
	if (_tiParam isEqualType "") exitWith {
		private _s = [toLower (trim _tiParam)] call _fnc_stripQuotes;
		if (_s in ["", "-1", "def", "default"]) exitWith { _isTiDefault = true; };
		if (_s in ["-2", "[]", "false"]) exitWith { _finalTi = []; };
		if (_s in ["true", "1"]) exitWith { _finalTi = [2, 7]; };

		private _compiled = call compile _s;
		if (!isNil "_compiled") then {
			if (_compiled isEqualType []) exitWith {
				if (_compiled isEqualTo [] || {_compiled isEqualTo [-2]}) exitWith { _finalTi = []; };
				if (_compiled isEqualTo [-1]) exitWith { _isTiDefault = true; };
				_finalTi = _compiled select {_x isEqualType 0 && {_x >= 0}};
			};
			if (_compiled isEqualType 0) exitWith {
				if (_compiled == -1) exitWith { _isTiDefault = true; };
				if (_compiled == -2) exitWith { _finalTi = []; };
				_finalTi = [_compiled];
			};
			if (_compiled isEqualType true) exitWith {
				_finalTi = if (_compiled) then {[2, 7]} else {[]};
			};
			_isTiDefault = true;
		} else {
			private _nums = (_s splitString SPLIT_CHARACTERS) apply {parseNumber _x} select {_x >= 0};
			if (_nums isNotEqualTo []) then {
				_finalTi = _nums;
			} else {
				_isTiDefault = true;
			};
		};
	};
	if (_tiParam isEqualType []) exitWith {
		if (_tiParam isEqualTo [] || {_tiParam isEqualTo [-2]} || {_tiParam isEqualTo ["-2"]}) exitWith {
			_finalTi = [];
		};
		if (_tiParam isEqualTo [-1] || {_tiParam isEqualTo ["-1"]}) exitWith {
			_isTiDefault = true;
		};
		private _modes = [];
		{
			if (_x isEqualType 0 && {_x >= 0}) then {
				_modes pushBack _x;
			} else {
				if (_x isEqualType "") then {
					private _trimmedX = trim _x;
					private _num = parseNumber _trimmedX;
					if (_trimmedX isNotEqualTo "" && {_num >= 0}) then {
						_modes pushBack _num;
					};
				};
			};
		} forEach _tiParam;
		_finalTi = _modes;
	};
	_isTiDefault = true;
};

if (_isNvgDefault || {_isTiDefault}) then {
	private _typeOp = _operator call CFM_fnc_getOperatorClass;
	private _camType = _operator call CFM_fnc_cameraType;
	private _cfgSection = if (_turretIdx == -1 && {_camType in [DRONETYPE]}) then {
		configFile >> "CfgVehicles" >> _typeOp >> "PilotCamera" >> "OpticsIn" >> "Wide"
	} else {
		configFile >> "CfgVehicles" >> _typeOp >> "Turrets" >> "MainTurret" >> "OpticsIn" >> "Wide"
	};

	if (_isNvgDefault) then {
		private _visionModes = getArray (_cfgSection >> "visionMode");
		_finalNvg = ("NVG" in _visionModes);
	};

	if (_isTiDefault) then {
		private _tiConfig = getArray (_cfgSection >> "thermalMode");
		private _tiModesTable = missionNamespace getVariable ["CFM_tiModesTable", createHashMap];
		_finalTi = _tiConfig apply {
			_tiModesTable getOrDefault [_x, 2]
		};
	};
};

if (IS_OBJ(_operator)) then {
	private _tiTable = _operator getVariable ["CFM_tiTable", createHashMap];
	_tiTable set [_turretIdx, _finalTi];
	_operator setVariable ["CFM_tiTable", _tiTable];

	private _nvgTable = _operator getVariable ["CFM_nvgTable", createHashMap];
	_nvgTable set [_turretIdx, _finalNvg];
	_operator setVariable ["CFM_nvgTable", _nvgTable];

	if (_finalTi isNotEqualTo []) then {
		_operator setVariable ["CFM_canSwitchTi", true];
	};
	if (_finalNvg) then {
		_operator setVariable ["CFM_canSwitchNvg", true];
	};
};

_finalTi = _finalTi - [0];

[_finalTi, _finalNvg]