#include "defines.hpp"

#define LGVAR _logic GV
#undef BOOL
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define OBJ_BOOL(obj, var, def) ((obj getVariable [var, def]) isEqualTo 1)

params [
	["_logic", objNull, [objNull]],
	["_units", [], [[]]],
	["_activated", true, [true]]
];

if (!_activated || {is3DEN}) exitWith {};

[_logic] spawn {
	params ["_logic"];

	if (BOOL("isCameraTurret", 0)) exitWith {};

	sleep 0.1;

	private _sidesStr = LGVAR ["cameraSides", ""];
	private _sideMap = createHashMapFromArray [
		["west", west], ["blufor", west],
		["east", east], ["opfor", east],
		["independent", independent], ["resistance", independent], ["guer", independent],
		["civilian", civilian], ["civ", civilian],
		["sidelogic", sideLogic], ["sideempty", sideEmpty], ["sideambientlife", sideAmbientLife]
	];

	private _sides = [];
	{
		private _s = _sideMap get (toLower trim _x);
		if (!isNil "_s") then {
			_sides pushBackUnique _s;
		};
	} forEach (_sidesStr splitString SPLIT_CHARACTERS);

	if (_sides isEqualTo []) exitWith {
		format ["CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %1", _sidesStr] WARN;
	};

	private _fnc_processArrayString = {
		params ["_l", "_offsetsStr", ["_isOffset", true]];
		private _trimmed = trim (toLower _offsetsStr);
		private _isThis = (_trimmed isEqualTo "this") || {_isOffset && {_trimmed isEqualTo ""}};
		
		if (_isOffset && {_isThis}) exitWith {
			[getPosASL _l, [vectorDir _l, vectorUp _l]]
		};

		private _res = [];
		if (!_isThis && {_trimmed isNotEqualTo ""}) then {
			_res = call compile _offsetsStr;
			if (isNil "_res") then { _res = []; };
		};

		if (_res isEqualTo []) exitWith {[]};
		if (_res isEqualType []) exitWith {+_res};
		_res
	};

	#include "fnc_parseTurretsSetting.sqf"

	private _fnc_processCameraParams = {
		params ["_camLogic", ["_turretIndex", -1], ["_setNvgAndTi", [-1, -1]]];

		private _name = _camLogic getVariable ["cameraName", ""];
		if (_name isEqualTo "") then {
			private _nums = toArray (hashValue _camLogic);
			private _num = 0;
			{ _num = _num + _x; } forEach _nums;
			_num = _num * (_nums param [0, 1]);
			_name = "Camera ID: " + str _num;
		};

		private _camObj = MGVAR [trim (_camLogic getVariable ["cameraObject", ""]), objNull];
		private _canMoveStr = toLower trim (_camLogic getVariable ["cameraCanMoveCamera", ""]);
		private _canMoveCam = call {
			if (_canMoveStr in ["true", ""/* FOR STATIC CAMERA SPECIFICLY DEFAULT EMPTY IS TRUE */]) exitWith {true};
			if (_canMoveStr in ["false", "0"]) exitWith {false};
			private _arr = (_canMoveStr splitString SPLIT_CHARACTERS) apply {parseNumber _x};
			if (_arr isEqualTo []) exitWith {false};
			_arr resize [4, 0];
			if (_arr isEqualTo [0,0,0,0]) exitWith {false};
			_arr
		};

		private _smoothZoom = OBJ_BOOL(_camLogic, "cameraSmoothZoom", 1);
		private _zoomParamsStr = _camLogic getVariable ["zoomParams", ""];
		private _zoomParams = [_camLogic, _zoomParamsStr, false] call _fnc_processArrayString;

		[
			_camObj,
			_canMoveCam,
			_turretIndex,
			_zoomParams,
			_setNvgAndTi,
			_name,
			_smoothZoom
		]
	};

	private _fnc_parseTurretIdx = {
		params ["_str"];
		private _trimmed = trim _str;
		if (_trimmed isEqualTo "") exitWith {nil};
		private _num = parseNumber _trimmed;
		if (_num != 0 || {_trimmed isEqualTo "0"}) exitWith {_num};
		nil
	};

	// Определение индексов турелей статической камеры
	private _mainTurrIdx = [LGVAR ["turretIndex", ""]] call _fnc_parseTurretIdx;
	if (isNil "_mainTurrIdx") then { _mainTurrIdx = -1; };
	private _allTurrets = [_mainTurrIdx];

	private _staticCamModuleClass = toLower "CFM_Module_Camera";
	private _syncedModules = (synchronizedObjects _logic) select {
		(toLower typeOf _x) isEqualTo _staticCamModuleClass && {OBJ_BOOL(_x, "isCameraTurret", 0)}
	};

	// Используем массив пар [_moduleObj, _sIdx], так как OBJECT не может быть ключом в HashMap
	private _syncedPairs = [];

	{
		private _sIdx = [_x getVariable ["turretIndex", ""]] call _fnc_parseTurretIdx;
		if (isNil "_sIdx") then {
			_sIdx = 0;
			while {_sIdx in _allTurrets} do { _sIdx = _sIdx + 1; };
		};
		_allTurrets pushBackUnique _sIdx;
		_syncedPairs pushBack [_x, _sIdx];
	} forEach _syncedModules;

	// Парсинг настроек NVG и TI для всех турелей
	private _nvgStr = _logic getVariable ["cameraHasNvg", "-1"];
	private _tiStr = _logic getVariable ["cameraHasTI", "-1"];
	private _nvgMap = [_nvgStr, false, _allTurrets, false] call _parseTurretsSetting;
	private _tiMap = [_tiStr, true, _allTurrets, false] call _parseTurretsSetting;

	private _fnc_isOverrideValid = {
		params ["_val"];
		if !(_val isEqualType "") exitWith {true};
		!(toLower (trim _val) in ["", "-1", "default"])
	};

	// Применение переопределений с синхронизированных модулей турелей
	{
		_x params ["_syncMod", "_sIdx"];
		
		private _sNvg = _syncMod getVariable ["cameraHasNvg", "-1"];
		if ([_sNvg] call _fnc_isOverrideValid) then {
			private _parsedSNvg = [_sNvg, false, [_sIdx], true] call _parseTurretsSetting;
			_nvgMap set [_sIdx, _parsedSNvg get _sIdx];
		};

		private _sTi = _syncMod getVariable ["cameraHasTI", "-1"];
		if ([_sTi] call _fnc_isOverrideValid) then {
			private _parsedSTi = [_sTi, true, [_sIdx], true] call _parseTurretsSetting;
			_tiMap set [_sIdx, _parsedSTi get _sIdx];
		};
	} forEach _syncedPairs;

	// Обработка основного модуля
	private _offsetsStr = LGVAR ["cameraTurretsCustom", "this"];
	private _mainOffset = [_logic, _offsetsStr] call _fnc_processArrayString;
	if (isNil "_mainOffset") then { _mainOffset = []; };

	private _offsets = [];
	private _mainNvgTi = [_nvgMap getOrDefault [_mainTurrIdx, -1], _tiMap getOrDefault [_mainTurrIdx, -1]];
	private _params = [_logic, _mainTurrIdx, _mainNvgTi] call _fnc_processCameraParams;

	if (_mainOffset isNotEqualTo []) then {
		_offsets pushBack ([_mainOffset] + _params);
	};

	// Обработка синхронизированных модулей
	{
		_x params ["_syncMod", "_sIdx"];
		private _turrOffsetsStr = _syncMod getVariable ["cameraTurretsCustom", "this"];
		private _turrOffsets = [_syncMod, _turrOffsetsStr] call _fnc_processArrayString;
		if (isNil "_turrOffsets" || {_turrOffsets isEqualTo []}) then { continue };

		private _sNvgTi = [_nvgMap getOrDefault [_sIdx, -1], _tiMap getOrDefault [_sIdx, -1]];
		private _turrParams = [_syncMod, _sIdx, _sNvgTi] call _fnc_processCameraParams;
		_offsets pushBack ([_turrOffsets] + _turrParams);
	} forEach _syncedPairs;

	if (_offsets isEqualTo []) exitWith {
		format ["CFM_fnc_initModuleCamera: ZERO OFFSETS GIVEN. Offset string: '%1'. Synced modules: '%2'", _offsetsStr, _syncedModules] WARN;
	};

	[
		_params param [5, ""],
		_offsets,
		_sides,
		_params param [0, objNull],
		[-1, -1],
		[
			_params param [1, -1],
			_params param [6, -1]
		]
	] call CFM_fnc_setStaticCamera;
};