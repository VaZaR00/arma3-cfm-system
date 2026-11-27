/*
    Function: CFM_fnc_updateDynamicHud
    Author: Vazar & Gemini
    Description:
        Per-frame telemetry updater for dynamically built HUD displays.
        Evaluates live operator/camera/monitor data for all bound widgets without touching global uiNamespace state.
    Parameters:
        0: _monitor [Object] - Monitor object.
        1: _operator [Object] - Connected operator/vehicle/UAV object.
        2: _signal [Number] - Current signal strength [0..1].
        3: _uiCtrlCurrentUIDisplay [Display] - Active HUD display instance.
        4: _uiDisplayUniqueName [String] - Unique display identifier.
    Returns:
        [Nothing]
*/

#include "defines.hpp"

params [
	["_monitor", objNull],
	["_operator", objNull],
	["_signal", 1],
	["_uiCtrlCurrentUIDisplay", displayNull],
	["_uiDisplayUniqueName", ""]
];

if (isNull _uiCtrlCurrentUIDisplay || {!(IS_OBJ(_operator))}) exitWith {};

private _bindings = _uiCtrlCurrentUIDisplay getVariable ["CFM_hudActiveBindings", []];
if (_bindings isEqualTo []) exitWith {};

private _monPair = _uiCtrlCurrentUIDisplay getVariable ["CFM_monitor", [_monitor, -1]];
_monPair params [["_monObj", objNull], ["_instId", -1]];
private _hasValidMon = IS_OBJ(_monObj) && {_instId > 0};

private _curCam = if (_hasValidMon) then {MON_GVAR(_monObj, _instId, "CFM_currentFeedCam", objNull)} else {objNull};
private _turretArr = if (_hasValidMon) then {MON_GVAR(_monObj, _instId, "CFM_currentTurret", [-1])} else {[-1]};
if (!(_turretArr isEqualType []) || {_turretArr isEqualTo []}) then {_turretArr = [-1];};
private _turretIdx = TURRET_INDEX(_turretArr);
private _turretPath = [_turretIdx];

private _camDir = if (IS_OBJ(_curCam)) then {vectorDir _curCam} else {vectorDirVisual _operator};
private _camPosASL = if (IS_OBJ(_curCam)) then {getPosASL _curCam} else {getPosASL _operator};

private _needRange = false;
{
	if ((_x select 1) in ["slant_range", "tgt_grid"]) exitWith {_needRange = true;};
} forEach _bindings;

private _lsrObj = objNull;
private _rangeStr = "----";
private _hitPosASL = [];

if (_needRange) then {
	_lsrObj = _operator laserTarget _turretPath;
	if (IS_OBJ(_lsrObj)) then {
		_hitPosASL = getPosASL _lsrObj;
		_rangeStr = format ["%1", round (_camPosASL distance _hitPosASL)];
		_uiCtrlCurrentUIDisplay setVariable ["CFM_hudLastRangeStr", _rangeStr];
		_uiCtrlCurrentUIDisplay setVariable ["CFM_hudLastHitPosASL", _hitPosASL];
	} else {
		private _lastRangeTime = _uiCtrlCurrentUIDisplay getVariable ["CFM_hudLastRangeTime", -999];
		if ((diag_tickTime - _lastRangeTime) >= DYN_HUD_RANGE_THROTTLE) then {
			_uiCtrlCurrentUIDisplay setVariable ["CFM_hudLastRangeTime", diag_tickTime];
			private _endPos = _camPosASL vectorAdd ((vectorNormalized _camDir) vectorMultiply 5000);
			private _hits = lineIntersectsSurfaces [_camPosASL, _endPos, _operator, objNull, true, 1, "GEOM", "NONE"];
			if !(_hits isEqualTo []) then {
				_hitPosASL = (_hits select 0) select 0;
				_rangeStr = format ["%1", round (_camPosASL distance _hitPosASL)];
			} else {
				_hitPosASL = [];
				_rangeStr = "----";
			};
			_uiCtrlCurrentUIDisplay setVariable ["CFM_hudLastRangeStr", _rangeStr];
			_uiCtrlCurrentUIDisplay setVariable ["CFM_hudLastHitPosASL", _hitPosASL];
		} else {
			_rangeStr = _uiCtrlCurrentUIDisplay getVariable ["CFM_hudLastRangeStr", "----"];
			_hitPosASL = _uiCtrlCurrentUIDisplay getVariable ["CFM_hudLastHitPosASL", []];
		};
	};
};

private _fnc_setCtrlText = {
	params ["_ctrl", "_ctrlType", "_textStr", "_structAttrs"];
	if (_ctrlType isEqualTo 13) exitWith {
		if ((_textStr find "<t") >= 0 || {(_textStr find "<img") >= 0}) exitWith {
			_ctrl ctrlSetStructuredText (parseText _textStr);
		};
		if !(_structAttrs isEqualTo []) exitWith {
			_structAttrs params [["_aFont", ""], ["_aColor", ""], ["_aAlign", ""], ["_aValign", ""], ["_aShadow", -1]];
			private _attrParts = [];
			if !(_aFont isEqualTo "") then {_attrParts pushBack format ["font='%1'", _aFont];};
			if !(_aColor isEqualTo "") then {_attrParts pushBack format ["color='%1'", _aColor];};
			if !(_aAlign isEqualTo "") then {_attrParts pushBack format ["align='%1'", _aAlign];};
			if (_aShadow >= 0) then {_attrParts pushBack format ["shadow='%1'", _aShadow];};
			if (_attrParts isEqualTo []) then {
				_ctrl ctrlSetStructuredText (parseText _textStr);
			} else {
				_ctrl ctrlSetStructuredText (parseText format ["<t %1>%2</t>", _attrParts joinString " ", _textStr]);
			};
		};
		_ctrl ctrlSetStructuredText (parseText _textStr);
	};
	_ctrl ctrlSetText _textStr;
};

private _fnc_pickSteppedPic = {
	params ["_steps", "_valPct"];
	if (_steps isEqualTo []) exitWith {""};
	private _maxStep = ((_steps select ((count _steps) - 1)) select 0) max 1;
	private _targetVal = if (_maxStep <= 10) then {(_valPct / 100) * _maxStep} else {_valPct};
	private _bestPath = (_steps select 0) select 1;
	private _bestDiff = 1e9;
	{
		_x params ["_step", "_path"];
		private _diff = abs (_targetVal - _step);
		if (_diff < _bestDiff) then {
			_bestDiff = _diff;
			_bestPath = _path;
		};
	} forEach _steps;
	_bestPath
};

private _fuelClamped = ((fuel _operator) max 0) min 1;
private _signalClamped = ((_signal max 0) min 1);

{
	_x params ["_ctrl", "_wKind", "_wMeta", "_ctrlType", ["_structAttrs", []]];
	if (isNull _ctrl) then {continue};

	switch (_wKind) do {
		case "igui_heading": {
			private _hdg = round ((((_camDir select 0) atan2 (_camDir select 1)) + 360) mod 360);
			if (_hdg isEqualTo 360) then {_hdg = 0;};
			private _hdgStr = if (_hdg < 10) then {
				format ["00%1", _hdg]
			} else {
				if (_hdg < 100) then {format ["0%1", _hdg]} else {str _hdg}
			};
			[_ctrl, _ctrlType, _hdgStr, _structAttrs] call _fnc_setCtrlText;
		};
		case "heading_deg": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _hdg = round ((((_camDir select 0) atan2 (_camDir select 1)) + 360) mod 360);
			if (_hdg isEqualTo 360) then {_hdg = 0;};
			[_ctrl, _ctrlType, format ["%1%2", _prefix, _hdg], _structAttrs] call _fnc_setCtrlText;
		};
		case "igui_zoom": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _opIsDrone = if (_hasValidMon) then {MON_GVAR(_monObj, _instId, "CFM_currentOperatorIsDrone", false)} else {false};
			private _zoomFov = if (_hasValidMon) then {
				if (_opIsDrone && {!(MGVAR ["CFM_canChangeZoomOnDrones", false])}) then {
					"op"
				} else {
					MON_GVAR(_monObj, _instId, "CFM_zoomFov", 1)
				}
			} else {1};

			private _zoomVal = 1;
			if (!(_zoomFov isEqualTo "op") && {_hasValidMon}) then {
				private _monZoom = MON_GVAR(_monObj, _instId, "CFM_zoom", 1);
				if (_monZoom isEqualType 0) then {
					_zoomVal = (round (_monZoom * 10)) / 10;
				};
			} else {
				private _baseFov = _uiCtrlCurrentUIDisplay getVariable "CFM_hudCachedBaseFov";
				if (isNil "_baseFov") then {
					private _vehCfg = configFile >> "CfgVehicles" >> (typeOf _operator);
					_baseFov = getNumber (_vehCfg >> "PilotCamera" >> "OpticsIn" >> "Wide" >> "maxFov");
					if (_baseFov <= 0) then {
						private _turrCfg = [_operator, _turretPath] call BIS_fnc_turretConfig;
						private _opticsWide = _turrCfg >> "OpticsIn" >> "Wide" >> "maxFov";
						if (isNumber _opticsWide) then {
							_baseFov = getNumber _opticsWide;
						} else {
							private _opticsCls = configProperties [_turrCfg >> "OpticsIn", "isClass _x", true];
							if !(_opticsCls isEqualTo []) then {
								_baseFov = getNumber ((_opticsCls select 0) >> "maxFov");
							};
						};
					};
					if (_baseFov <= 0) then {_baseFov = 0.75;};
					_uiCtrlCurrentUIDisplay setVariable ["CFM_hudCachedBaseFov", _baseFov];
				};
				private _curFov = _operator getVariable ["CFM_prevZoomLocalFov", getObjectFOV _operator];
				if (_curFov <= 0.001) then {_curFov = _baseFov;};
				_zoomVal = (round (((_baseFov / _curFov) max 0.1) * 10)) / 10;
			};
			[_ctrl, _ctrlType, format ["%1%2x", _prefix, _zoomVal], _structAttrs] call _fnc_setCtrlText;
		};
		case "igui_vision": {
			private _pipEff = if (_hasValidMon) then {MON_GVAR(_monObj, _instId, "CFM_currentPiPEffect", 0)} else {0};
			private _modeStr = switch (_pipEff) do {
				case 0: {"DTV"};
				case 1: {"NVG"};
				case 2: {"WHOT"};
				case 7: {"BHOT"};
				default {"TI"};
			};
			[_ctrl, _ctrlType, _modeStr, _structAttrs] call _fnc_setCtrlText;
		};
		case "igui_flir": {
			private _pipEff = if (_hasValidMon) then {MON_GVAR(_monObj, _instId, "CFM_currentPiPEffect", 0)} else {0};
			private _flirStr = switch (_pipEff) do {
				case 2: {"WHOT"};
				case 7: {"BHOT"};
				default {if (_pipEff >= 2) then {"TI"} else {""}};
			};
			[_ctrl, _ctrlType, _flirStr, _structAttrs] call _fnc_setCtrlText;
		};
		case "laser": {
			private _isLsr = (_operator isLaserOn _turretPath) || {!(isNull (_operator laserTarget _turretPath))};
			if (_wMeta isEqualTo true) then {
				_ctrl ctrlShow _isLsr;
			} else {
				[_ctrl, _ctrlType, ["", "LSR"] select _isLsr, _structAttrs] call _fnc_setCtrlText;
			};
		};
		case "slant_range": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			[_ctrl, _ctrlType, format ["%1%2", _prefix, _rangeStr], _structAttrs] call _fnc_setCtrlText;
		};
		case "altitude": {
			private _prefix = "";
			private _unit = "";
			private _isAsl = false;
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", ""], ["_a", false]];
				_prefix = _p;
				_unit = _u;
				_isAsl = _a;
			};
			private _alt = if (_isAsl) then {round ((getPosASLVisual _operator) select 2)} else {floor (_operator call CBA_fnc_realHeight)};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _alt, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "speed": {
			private _prefix = "";
			private _unit = "";
			private _isMs = false;
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", ""], ["_ms", false]];
				_prefix = _p;
				_unit = _u;
				_isMs = _ms;
			};
			private _spd = if (_isMs) then {floor ((speed _operator) / 3.6)} else {floor (speed _operator)};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _spd, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "vspeed": {
			private _prefix = "";
			private _unit = " m/s";
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", " m/s"]];
				_prefix = _p;
				_unit = _u;
			};
			private _vs = floor ((velocityModelSpace _operator) select 2);
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _vs, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "pitch": {
			private _prefix = "";
			private _unit = "°";
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", "°"]];
				_prefix = _p;
				_unit = _u;
			};
			private _pitchVal = if (_prefix isEqualTo "") then {
				round (asin ((((vectorNormalized _camDir) select 2) max -1) min 1))
			} else {
				floor ((_operator call BIS_fnc_getPitchBank) select 0)
			};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _pitchVal, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "bank": {
			private _prefix = "";
			private _unit = "°";
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", "°"]];
				_prefix = _p;
				_unit = _u;
			};
			private _bankVal = floor ((_operator call BIS_fnc_getPitchBank) select 1);
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _bankVal, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "own_grid": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			[_ctrl, _ctrlType, format ["%1%2", _prefix, mapGridPosition _operator], _structAttrs] call _fnc_setCtrlText;
		};
		case "tgt_grid": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _tgtStr = if (IS_OBJ(_lsrObj)) then {
				mapGridPosition _lsrObj
			} else {
				if !(_hitPosASL isEqualTo []) then {
					mapGridPosition (ASLToAGL _hitPosASL)
				} else {
					"------"
				}
			};
			[_ctrl, _ctrlType, format ["%1%2", _prefix, _tgtStr], _structAttrs] call _fnc_setCtrlText;
		};
		case "square_x": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _posATL = getPosATLVisual _operator;
			[_ctrl, _ctrlType, format ["%1%2", _prefix, floor ((_posATL select 0) / 100)], _structAttrs] call _fnc_setCtrlText;
		};
		case "square_y": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _posATL = getPosATLVisual _operator;
			[_ctrl, _ctrlType, format ["%1%2", _prefix, floor ((_posATL select 1) / 100)], _structAttrs] call _fnc_setCtrlText;
		};
		case "clock_time": {
			[_ctrl, _ctrlType, [dayTime, "HH:MM:SS"] call BIS_fnc_timeToString, _structAttrs] call _fnc_setCtrlText;
		};
		case "date_text": {
			private _d = date;
			[_ctrl, _ctrlType, format ["%1/%2/%3", _d select 2, _d select 1, _d select 0], _structAttrs] call _fnc_setCtrlText;
		};
		case "rem_time": {
			private _remSec = floor (1800 * _fuelClamped);
			private _usePrime = !isNil "_wMeta" && {_wMeta isEqualTo true};
			private _timeStr = if (_usePrime) then {
				private _mins = floor (_remSec / 60);
				private _secs = floor (_remSec mod 60);
				private _secStr = if (_secs < 10) then {format ["0%1", _secs]} else {str _secs};
				format ["%1'%2""", _mins, _secStr]
			} else {
				[_remSec, "MM:SS"] call BIS_fnc_secondsToString
			};
			[_ctrl, _ctrlType, _timeStr, _structAttrs] call _fnc_setCtrlText;
		};
		case "on_time": {
			private _startTime = _operator getVariable "CFM_opFeedStartTime";
			if (isNil "_startTime") then {
				_startTime = time;
				_operator setVariable ["CFM_opFeedStartTime", _startTime];
			};
			private _elapsed = (time - _startTime) max 0;
			private _usePrime = !isNil "_wMeta" && {_wMeta isEqualTo true};
			private _timeStr = if (_usePrime) then {
				private _mins = floor (_elapsed / 60);
				private _secs = floor (_elapsed mod 60);
				private _secStr = if (_secs < 10) then {format ["0%1", _secs]} else {str _secs};
				format ["%1'%2""", _mins, _secStr]
			} else {
				[_elapsed, "MM:SS"] call BIS_fnc_secondsToString
			};
			[_ctrl, _ctrlType, _timeStr, _structAttrs] call _fnc_setCtrlText;
		};
		case "battery_text": {
			private _prefix = "";
			private _unit = "";
			private _isVolts = false;
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", ""], ["_v", false]];
				_prefix = _p;
				_unit = _u;
				_isVolts = _v;
			};
			private _valStr = if (_isVolts) then {
				str ((round ((3.0 + (1.2 * _fuelClamped)) * 100)) / 100)
			} else {
				str (floor (_fuelClamped * 100))
			};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, _valStr, _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "signal_text": {
			private _prefix = "";
			private _unit = "";
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", ""]];
				_prefix = _p;
				_unit = _u;
			};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, round (_signalClamped * 100), _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "op_distance": {
			private _prefix = "";
			private _unit = "";
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				_wMeta params [["_p", ""], ["_u", ""]];
				_prefix = _p;
				_unit = _u;
			};
			[_ctrl, _ctrlType, format ["%1%2%3", _prefix, floor (_monitor distance _operator), _unit], _structAttrs] call _fnc_setCtrlText;
		};
		case "temperature": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			[_ctrl, _ctrlType, format ["%1%2°C", _prefix, floor (ambientTemperature select 0)], _structAttrs] call _fnc_setCtrlText;
		};
		case "flight_status": {
			private _prefix = if (!isNil "_wMeta" && {_wMeta isEqualType ""}) then {_wMeta} else {""};
			private _st = ["IN FLIGHT", "GROUNDED"] select (isTouchingGround _operator);
			[_ctrl, _ctrlType, format ["%1%2", _prefix, _st], _structAttrs] call _fnc_setCtrlText;
		};
		case "pic_battery": {
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				private _path = [_wMeta, _fuelClamped * 100] call _fnc_pickSteppedPic;
				if !(_path isEqualTo "") then {
					_ctrl ctrlSetText _path;
				};
			};
		};
		case "pic_signal";
		case "pic_sat": {
			if (!isNil "_wMeta" && {_wMeta isEqualType []}) then {
				private _path = [_wMeta, _signalClamped * 100] call _fnc_pickSteppedPic;
				if !(_path isEqualTo "") then {
					_ctrl ctrlSetText _path;
				};
			};
		};
		case "prog_battery": {
			_ctrl progressSetPosition _fuelClamped;
		};
		case "prog_signal": {
			_ctrl progressSetPosition _signalClamped;
		};
		case "custom": {
			if (!isNil "_wMeta" && {_wMeta isEqualType {}}) then {
				[_ctrl, _monitor, _operator, _signal, _uiCtrlCurrentUIDisplay, _uiDisplayUniqueName] call _wMeta;
			};
		};
		default {};
	};
} forEach _bindings;
