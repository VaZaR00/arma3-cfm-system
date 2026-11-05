#include "defines.hpp"

#define LGVAR _logic GV
#undef BOOL
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define OBJ_BOOL(obj, var, def) ((obj getVariable [var, def]) isEqualTo 1)
#define SELECT_DEF(var, def) (call {private _val = (LGVAR [var, def]); if (_val isEqualTo -1) then {-1} else {_val isEqualTo 1}})

params [
["_logic", objNull, [objNull]],
["_units", [], [[]]],
["_activated", true, [true]]
];

if (!_activated || {is3DEN}) exitWith {};

[_logic] spawn {
	params ["_logic"];

	sleep 0.1;

	if (BOOL("isCameraTurret", 0)) exitWith {};

	// ------- ОБЪЕКТЫ И КЛАССЫ ОПЕРАТОРОВ ---------
	private _syncedObjs = synchronizedObjects _logic;
	private _operatorsStr = LGVAR ["cameraObject", ""];
	private _operatorClasses = [];
	private _argumentsNotProcessed = [];
	private _operators = [];

	private _fnc_isValidVehicle = {
		(_this isKindOf "Land") || {_this isKindOf "Air"} || {_this isKindOf "Ship"}
	};

	{
		if (_x isEqualType objNull) then {
			if (_x call _fnc_isValidVehicle) then {
				_operators pushBackUnique _x;
			};
		} else {
			private _token = trim _x;
			if ("""" in _token || {"'" in _token}) then {
				// Имена классов в кавычках
				private _class = call compile _token;
				if (isNil "_class" || {!(_class isEqualType "")}) then {
					_argumentsNotProcessed pushBack _token;
				} else {
					_operatorClasses pushBackUnique _class;
				};
			} else {
				private _op = missionNamespace getVariable [_token, objNull];
				if (!IS_OBJ(_op)) then {
					_argumentsNotProcessed pushBack _token;
				} else {
					if (_op call _fnc_isValidVehicle) then {
						_operators pushBackUnique _op;
					};
				};
			};
		};
	} forEach (_syncedObjs + (_operatorsStr splitString SPLIT_CHARACTERS));

	private _hasNoOperatorObjs = (_operators isEqualTo []);

	// ------------- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ -------------
	private _fnc_parseCanMove = {
		params ["_str"];
		private _clean = toLower (trim _str);
		if (_clean isEqualTo "true") exitWith {true};
		if (_clean in ["false", ""]) exitWith {false};
		private _arr = (_clean splitString SPLIT_CHARACTERS) apply {parseNumber _x};
		if (_arr isEqualTo []) exitWith {false};
		_arr resize [4, 0];
		_arr
	};

	private _fnc_processArrayString = {
		params ["_l", "_offsetsStr", ["_mainObject", objNull], ["_memPoint", ""], ["_lod", "memory"]];
		private _cleanStr = trim (toLower _offsetsStr);
		private _forObj = IS_OBJ(_mainObject);

		if (_cleanStr in ["default", ""]) exitWith {
			if (_memPoint isEqualTo "") then {[]} else {[[_memPoint, _lod]]}
		};

		private _res = [];
		private _isThis = (_cleanStr isEqualTo "this");

		if (_isThis && {_forObj}) then {
			private _relPosModule = _mainObject worldToModelVisual (ASLToAGL getPosASL _l);
			private _relDirModule = _mainObject vectorWorldToModelVisual (vectorDir _l);
			private _relUpModule = _mainObject vectorWorldToModelVisual (vectorUp _l);

			if (_memPoint isEqualTo "") then {
				_res = [
					_relPosModule,
					[_relDirModule, _relUpModule]
				];
			} else {
				private _memPointPos = _mainObject selectionPosition [_memPoint, _lod];
				private _memPointDirUp = _mainObject selectionVectorDirAndUp [_memPoint, _lod];
				private _translatedDirUp = [_memPointDirUp, [_relDirModule, _relUpModule]] call CFM_fnc_translateLocalVectors;
				_res = [
					[_memPoint, _lod],
					_relPosModule vectorDiff _memPointPos,
					_translatedDirUp # 0,
					_translatedDirUp # 1
				];
			};
		};

		if (!_isThis && {_cleanStr isNotEqualTo ""}) then {
			_res = call compile _offsetsStr;
			if (!isNil "_res" && {_memPoint isNotEqualTo ""} && {_res isEqualType []} && {_res isNotEqualTo []}) then {
				private _firstElem = _res param [0, []];
				private _hasMemPoint = (_firstElem isEqualType "") || {(_firstElem isEqualType []) && {(_firstElem param [0, 0]) isEqualType ""}};
				if (!_hasMemPoint) then {
					_res = [[_memPoint, _lod]] + _res;
				};
			};
		};

		if (isNil "_res" || {_res isEqualTo []}) exitWith {[]};
		if (_res isEqualType []) exitWith {+_res};
		_res
	};

	#include "fnc_parseTurretsSetting.sqf"

	private _fnc_processTurretModule = {
		params ["_moduleLogic", ["_mainObj", objNull], ["_isMainModule", false], ["_setNvgAndTi", [-1, -1]]];

		if (!_isMainModule && {!(OBJ_BOOL(_moduleLogic, "isCameraTurret", 0))}) exitWith {[]};

		private _memPointLodStr = _moduleLogic getVariable ["cameraMemoryPoint", ""];
		private _memPointLod = _memPointLodStr splitString (trim SPLIT_CHARACTERS);
		_memPointLod params [
			["_memPoint", ""],
			["_lod", "memory"]
		];

		private _turrOffsetsStr = _moduleLogic getVariable ["cameraTurretsCustom", ""];
		if (!_isMainModule && {trim _turrOffsetsStr isEqualTo ""}) then {
			_turrOffsetsStr = "this";
		};

		private _turrOffsets = [_moduleLogic, _turrOffsetsStr, _mainObj, _memPoint, _lod] call _fnc_processArrayString;
		if (isNil "_turrOffsets") then { _turrOffsets = []; };

		private _zoomParams = [_moduleLogic, _moduleLogic getVariable ["zoomParams", ""], objNull] call _fnc_processArrayString;
		private _camObj = MGVAR [trim (_moduleLogic getVariable ["cameraObject", ""]), objNull];
		if (_camObj in _operators) then {
			_camObj = objNull;
		};

		private _canMoveCam = [_moduleLogic getVariable ["cameraCanMoveCamera", ""]] call _fnc_parseCanMove;
		private _pointParams = if (_turrOffsets isEqualTo []) then {-1} else {_turrOffsets};

		[
			_camObj,
			_canMoveCam,
			_zoomParams,
			_setNvgAndTi,
			_pointParams,
			true,
			_moduleLogic getVariable ["cameraName", ""],
			OBJ_BOOL(_moduleLogic, "cameraSmoothZoom", 1)
		]
	};

	// ----------- ОСНОВНЫЕ ПАРАМЕТРЫ -------------
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

	if (!_hasNoOperatorObjs && {_sides isEqualTo []}) then {
		_sides = [side (_operators # 0)];
	};

	if (_hasNoOperatorObjs && {_sides isEqualTo []}) exitWith {
		format ["Module '%1'. CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %2", _logic, _sidesStr] WARN;
	};

	private _name = LGVAR ["cameraName", ""];
	private _canMoveCam = [LGVAR ["cameraCanMoveCamera", ""]] call _fnc_parseCanMove;
	private _smoothZoom = BOOL("cameraSmoothZoom", 1);

	// ------ ЕСЛИ НЕТ ОПЕРАТОРОВ -> СТАТИЧЕСКАЯ КАМЕРА --------
	if (_operators isEqualTo [] && {_operatorClasses isEqualTo []}) exitWith {
		[_logic] call CFM_fnc_initModuleStaticCamera;
	};

	// --- ОБРАБОТКА ТУРЕЛЕЙ И NVG/TI ДЛЯ ОПЕРАТОРОВ ---
	private _fnc_parseTurretIdx = {
		params ["_str"];
		private _trimmed = trim _str;
		if (_trimmed isEqualTo "") exitWith {nil};
		private _num = parseNumber _trimmed;
		if (_num != 0 || {_trimmed isEqualTo "0"}) exitWith {_num};
		nil
	};

	private _mainTurrIdx = [LGVAR ["turretIndex", ""]] call _fnc_parseTurretIdx;
	if (isNil "_mainTurrIdx") then { _mainTurrIdx = -1; };
	private _allTurrets = [_mainTurrIdx];

	private _staticCamModuleClass = toLower "CFM_Module_Camera";
	private _syncedTurretModules = _syncedObjs select {
		(toLower typeOf _x) isEqualTo _staticCamModuleClass && {OBJ_BOOL(_x, "isCameraTurret", 0)}
	};

	// Ключ в HashMap - числовой индекс турели (_sTurrIdx), значение - объект модуля (_x)
	private _turretIdxToModuleMap = createHashMap;
	private _syncedTurretPairs = [];

	{
		private _sTurrIdx = [_x getVariable ["turretIndex", ""]] call _fnc_parseTurretIdx;
		if (isNil "_sTurrIdx") then {
			_sTurrIdx = 0;
			while {_sTurrIdx in _allTurrets} do { _sTurrIdx = _sTurrIdx + 1; };
		};
		_allTurrets pushBackUnique _sTurrIdx;
		_turretIdxToModuleMap set [_sTurrIdx, _x];
		_syncedTurretPairs pushBack [_x, _sTurrIdx];
	} forEach _syncedTurretModules;

	// Проверка наличия стрелковой турели у БПЛА/объекта
	private _mainObject = _operators param [0, objNull];
	if (IS_OBJ(_mainObject)) then {
		private _camType = [_mainObject] call CFM_fnc_cameraType;
		private _fullCrew = fullCrew [_mainObject, "", true];
		private _hasGunner = (_fullCrew findIf {(_x # 1) isEqualTo "gunner"}) != -1;
		if (count _fullCrew > 1 && {_hasGunner} && {_camType isEqualTo DRONETYPE}) then {
			_allTurrets pushBackUnique 0;
		};
	} else {
		if (_operatorClasses isNotEqualTo []) then {
			private _cls = _operatorClasses select 0;
			if (
				getNumber (configFile >> "CfgVehicles" >> _cls >> "isUav") == 1 &&
				{isClass (configFile >> "CfgVehicles" >> _cls >> "Turrets" >> "MainTurret")}
			) then {
				_allTurrets pushBackUnique 0;
			};
		};
	};

	// Парсинг настроек NVG и TI
	private _nvgStr = _logic getVariable ["cameraNVGParams", "-1"];
	private _tiStr = _logic getVariable ["cameraTIParams", "-1"];
	private _nvgMap = [_nvgStr, false, _allTurrets, false] call _parseTurretsSetting;
	private _tiMap = [_tiStr, true, _allTurrets, false] call _parseTurretsSetting;

	private _fnc_isOverrideValid = {
		params ["_val"];
		if !(_val isEqualType "") exitWith {true};
		!(toLower (trim _val) in ["", "-1", "default"])
	};

	// Применение переопределений с синхронизированных модулей
	{
		_x params ["_syncMod", "_sTurrIdx"];
		
		private _sNvg = _syncMod getVariable ["cameraNVGParams", "-1"];
		if ([_sNvg] call _fnc_isOverrideValid) then {
			private _parsedSNvg = [_sNvg, false, [_sTurrIdx], true] call _parseTurretsSetting;
			_nvgMap set [_sTurrIdx, _parsedSNvg get _sTurrIdx];
		};

		private _sTi = _syncMod getVariable ["cameraTIParams", "-1"];
		if ([_sTi] call _fnc_isOverrideValid) then {
			private _parsedSTi = [_sTi, true, [_sTurrIdx], true] call _parseTurretsSetting;
			_tiMap set [_sTurrIdx, _parsedSTi get _sTurrIdx];
		};
	} forEach _syncedTurretPairs;

	// Сборка _turretsCustom для CFM_fnc_setOperator
	private _turretsCustom = [];
	{
		private _tIdx = _x;
		private _turrNvgTi = [
			_nvgMap getOrDefault [_tIdx, -1],
			_tiMap getOrDefault [_tIdx, -1]
		];

		if (_tIdx == _mainTurrIdx) then {
			private _turrParams = [_logic, _mainObject, true, _turrNvgTi] call _fnc_processTurretModule;
			_turretsCustom pushBack [_tIdx, _turrParams];
		} else {
			private _foundMod = _turretIdxToModuleMap getOrDefault [_tIdx, objNull];

			if (IS_OBJ(_foundMod)) then {
				private _turrParams = [_foundMod, _mainObject, false, _turrNvgTi] call _fnc_processTurretModule;
				_turretsCustom pushBack [_tIdx, _turrParams];
			} else {
				_turretsCustom pushBack [_tIdx, [objNull, -1, [], _turrNvgTi, -1, true, "", -1]];
			};
		};
	} forEach _allTurrets;

	// Вызов CFM_fnc_setOperator
	if (_operatorClasses isNotEqualTo []) then {
		[
			_operatorClasses,
			_sides,
			_turretsCustom,
			[-1, -1],
			_name,
			[_canMoveCam, _smoothZoom]
		] call CFM_fnc_setOperator;
	};

	if (_operators isNotEqualTo []) then {
		[
			_operators,
			_sides,
			_turretsCustom,
			[-1, -1],
			_name,
			[_canMoveCam, _smoothZoom]
		] call CFM_fnc_setOperator;
	};
};