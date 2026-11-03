#include "defines.hpp"

#define LGVAR _logic GV 
#undef BOOL
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define OBJ_BOOL(obj, var, def) ((obj getVariable [var, def]) isEqualTo 1)
#define SELECT_DEF(var, def) (call {private _val = (LGVAR [var, def]); if (_val isEqualTo -1) then {-1} else {_val isEqualTo 1}})

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	sleep 0.1;	

	// if just turret dont proccess
	private _isJustTurret = BOOL("isCameraTurret", 0);
	if (_isJustTurret) exitWith {};

	// ------- OPERATOR OBJECTS AND CLASSES PARAMS ---------
		private _syncedObjs = (synchronizedObjects _logic);
		private _operatorsStr = LGVAR ["cameraObject", ""];
		private _operatorClasses = [];
		private _argumentsNotProccessed = [];
		private ["_class", "_op"];
		private _objectCondition = {(_this isKindOf "Land") || (_this isKindOf "Air") || (_this isKindOf "Ship")};
		private _operators = [];
		{
			if (_x isEqualType objNull) then {
				if (_x call _objectCondition) then {
					_operators pushBackUnique _x;
				};
			} else {
				if (("""" in _x) || ("'" in _x)) then {
					comment "Classnames (strings)";
					_class = call compile _x;
					if (isNil "_class") then {
						_argumentsNotProccessed pushBack _x;
					} else {
						_operatorClasses pushBackUnique _class;
					};
				} else {
					_op = missionNamespace getVariable _x;
					if ((isNil "_op") || {!(IS_OBJ(_op))}) then {
						_argumentsNotProccessed pushBack _x;
					} else {
						if (_op call _objectCondition) then {
							_operators pushBackUnique _op;
						};
					};
				};
			};
		} forEach (_syncedObjs + (_operatorsStr splitString SPLIT_CHARACTERS));
		private _hasNoOperatorObjs = _operators isEqualTo [];
	// ---------------------------------------

	// ------------- FUNCTIONS -------------
		private _proccessArrayString = {
			params["_l", "_offsetsStr", ["_mainObject", objNull], ["_memPoint", ""], ["_lod", "memory"]];
			private _res = [];
			_offsetsStr = trim (tolower _offsetsStr);
			private _forObj = IS_OBJ(_mainObject);
			private _isDefOrEmpty = (_offsetsStr isEqualTo "default") || (_offsetsStr isEqualTo "");
			if (_isDefOrEmpty) exitWith {
				if (_memPoint isEqualTo "") then {
					[]
				} else {
					[[_memPoint, _lod]]
				};
			};
			private _isThis = (_offsetsStr isEqualTo "this");
			if (_isThis && _forObj) then {
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
						_translatedDirUp#0, 
						_translatedDirUp#1
					];
				};
			};
			if (!_isThis && {!(_offsetsStr isEqualTo "")}) then {
				_res = call compile _offsetsStr;
				if (!(_memPoint isEqualTo "") && {(_res isEqualType []) && {!(_res isEqualTo [])}}) then {
					private _firstElem = _res param [0, []];
					private _hasMemPoint = (_firstElem isEqualType "") || {(_firstElem isEqualType []) && {(_firstElem param [0, 0]) isEqualType ""}};
					if !(_hasMemPoint) then {
						_res = [[_memPoint, _lod]] + _res;
					};
				};
			};
			if (isNil "_res") then {
				_res = [];
			};
			if (_res isEqualTo []) exitWith {[]};
			if (_res isEqualType []) exitWith {+_res};
			_res
		};
		private _proccessTurretModule = {
			params["_logic", ["_mainObj", objNull], ["_checkPointParams", false], ["_isMainModule", false]];

			// skip if its not set as turret
			if (!_isMainModule && {!(BOOL("isCameraTurret", 0))}) exitWith {[]};

			private _memPointLodStr = _logic getVariable ["cameraMemoryPoint", ""];

			private _memPointLod = _memPointLodStr splitString (trim SPLIT_CHARACTERS);
			_memPointLod params [
				["_memPoint", ""],
				["_lod", "memory"]
			];

			private _turrOffsetsStr = _logic getVariable ["cameraTurretsCustom", ""];
			if (!_isMainModule && {trim _turrOffsetsStr isEqualTo ""}) then {
				_turrOffsetsStr = "this";
			};
			private _turrOffsets = [_logic, _turrOffsetsStr, _mainObj, _memPoint, _lod] call _proccessArrayString;
			if (isNil "_turrOffsets") then {
				_turrOffsets = [];
			};
			private _zoomParams = [_logic, (LGVAR ["zoomParams", ""]), objNull] call _proccessArrayString;
			private _turretIndexStr = trim (LGVAR ["turretIndex", ""]);
			private _camObj = MGVAR [trim (LGVAR ["cameraObject", ""]), objNull];
			if (_camObj in _operators) then {
				_camObj = objNull;
			};
			if (_checkPointParams && {_turrOffsets isEqualTo []} && {_zoomParams isEqualTo []} && {_turretIndexStr isEqualTo ""} && {!IS_OBJ(_camObj)}) exitWith {[]};
			private _canMoveCam = (toLower (trim (LGVAR ["cameraCanMoveCamera", ""]))) call {
				if (_this isEqualTo "true") exitWith {true};
				if (_this isEqualTo "false" || {_this isEqualTo ""}) exitWith {false};
				private _canMoveCamArr = _this splitString SPLIT_CHARACTERS;
				_canMoveCamArr = _canMoveCamArr apply {parseNumber _x};
				if (_canMoveCamArr isEqualTo []) exitWith {false};
				_canMoveCamArr resize [4, 0];
				_canMoveCamArr
			};
			private _pointParams = if (_turrOffsets isEqualTo []) then {-1} else {_turrOffsets};
			private _turrParams = [
				_camObj,
				_canMoveCam,
				_zoomParams,
				[BOOL("cameraHasNvg", 1), BOOL("cameraHasTI", 1)],
				_pointParams,
				true,
				LGVAR ["cameraName", ""],
				BOOL("cameraSmoothZoom", 1)
			];
			private _turretIndex = parseNumber _turretIndexStr;
			if (
				!(_turretIndexStr isEqualTo "") && {
					((_turretIndex == 0) && (_turretIndexStr isEqualTo "0")) ||
					(_turretIndex != 0)
				}
			) then {
				_turrParams = [_turretIndex, _turrParams];
			};
			_turrParams
		};
	// ---------------------------------------

	// ----------- MAIN PARAMS -------------
		// SIDES
		private _sidesStr = LGVAR ["cameraSides", ""];
		private _sides = (_sidesStr splitString SPLIT_CHARACTERS) apply {
			private _compile = call compile _x;
			if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
				false
			} else {
				_compile
			};
		};
		_sides = _sides select {_x isEqualType west};
		if (!_hasNoOperatorObjs && {(_sides isEqualTo [])}) then {
			_sides = [side (_operators#0)];
		};

		if (_hasNoOperatorObjs && {(_sides isEqualTo [])}) exitWith {
			format["Module '%1'. CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %2", _logic, _sidesStr] WARN
		};

		// _pointParams: [_memPoint, ["_addArr", ["_dir", "_up"], "_setArr"]]
		// _turretsCustom: [[turrIndex, [_turretObject, _canMoveCamera, _setZoomTable, _setNvgAndTi, _pointParams, _doInterpolationSet, _turretName, _smoothZoomSetTurr]]]

		private _nvgTi = [SELECT_DEF("cameraHasTI", 1), SELECT_DEF("cameraHasNvg", 1)];

		private _name = LGVAR ["cameraName", ""];
		private _canMoveCam = (toLower (trim (LGVAR ["cameraCanMoveCamera", ""]))) call {
			if (_this isEqualTo "true") exitWith {true};
			if (_this isEqualTo "false" || {_this isEqualTo ""}) exitWith {false};
			private _canMoveCamArr = _this splitString SPLIT_CHARACTERS;
			_canMoveCamArr = _canMoveCamArr apply {parseNumber _x};
			if (_canMoveCamArr isEqualTo []) exitWith {false};
			_canMoveCamArr resize [4, 0];
			_canMoveCamArr
		};
		private _smoothZoom = BOOL("cameraSmoothZoom", 1);
	// ---------------------------------------

	// -------- PROCCESS OPERATOR CLASSES --------
		if !(_operatorClasses isEqualTo []) then {
			private _turretsCustom = [];
			private _turretParamsMain = [_logic, objNull, true, true] call _proccessTurretModule;
			if !(_turretParamsMain isEqualTo []) then {
				_turretsCustom pushBack _turretParamsMain;
			};
			[
				_operatorClasses,
				_sides,
				_turretsCustom,
				_nvgTi,
				_name,
				[
					_canMoveCam,
					_smoothZoom
				]
			] call CFM_fnc_setOperator;
		};
	// ---------------------------------------

	// ------ PROCCESS IF STATIC CAMERA --------
	if (_operators isEqualTo []) exitWith {
		if (_operatorClasses isEqualTo []) then {
			[_logic] call CFM_fnc_initModuleStaticCamera;
		};
	};
	// ---------------------------------------

	// --- PROCCESS OPERATORS OBJECTS AND TURRET MODULES ---
		private _staticCamModuleClass = (tolower "CFM_Module_Camera");
		private _syncedTurretModules = _syncedObjs select {(tolower typeOf _x) isEqualTo _staticCamModuleClass};
		private _mainObject = _operators param [0, objNull];
		private _turretsCustom = [];
		// get the offset of main module
		private _turretParamsMain = [_logic, _mainObject, true, true] call _proccessTurretModule;
		if !(_turretParamsMain isEqualTo []) then {
			_turretsCustom pushBack _turretParamsMain;
		};
		{
			private _turretModuleParams = [_x, _mainObject, false, false] call _proccessTurretModule;
			if (_turretModuleParams isEqualTo []) then {continue};
			_turretsCustom pushBack _turretModuleParams;
		} forEach _syncedTurretModules;
		private _args = [
			_operators,
			_sides,
			_turretsCustom,
			_nvgTi,
			_name,
			[
				_canMoveCam,
				_smoothZoom
			]
		];
		_args call CFM_fnc_setOperator;
	// ---------------------------------------
};
