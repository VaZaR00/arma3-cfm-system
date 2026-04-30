#include "defines.h"

#define LGVAR _logic GV 
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

	// ------------- FUNCTIONS -------------
		private _proccessArrayString = {
			params["_l", "_offsetsStr", ["_mainObject", objNull]];
			private _res = [];
			_offsetsStr = trim (tolower _offsetsStr);
			private _forObj = IS_OBJ(_mainObject);
			if (_forObj && {(_offsetsStr isEqualTo "default")}) exitWith {[]};;
			private _isThis = (_offsetsStr isEqualTo "this");
			if (_isThis && _forObj) then {
				private _relPosModule = _mainObject worldToModelVisual (getPos _l);
				private _relDirModule = _mainObject vectorWorldToModelVisual (vectorDir _l);
				private _relUpModule = _mainObject vectorWorldToModelVisual (vectorUp _l);
				private _memPointPos = _mainObject selectionPosition [_memPoint, _lod];
				private _memPointDirUp = _mainObject selectionVectorDirAndUp [_memPoint, _lod];
				_res = [
					[_memPoint, _lod],
					_relPosModule vectorDiff _memPointPos, 
					_relDirModule vectorDiff (_memPointDirUp#0), 
					_relUpModule vectorDiff (_memPointDirUp#1)
				];
			};
			if (!_isThis && {!(_offsetsStr isEqualTo "")}) then {
				_res = call compile _offsetsStr;
			};
			if (isNil "_res") then {
				_res = [];
			};
			if (_res isEqualTo []) exitWith {[]};
			+_res
		};
		private _proccessTurretModule = {
			params["_logic", ["_mainObj", objNull], ["_checkPointParams", false]];

			// skip if its not set as turret
			if !(BOOL("isCameraTurret", 0)) then {continue};

			private _memPointLodStr = _logic getVariable ["cameraMemoryPoint", ""];

			private _memPointLod = _memPointLodStr splitString (trim SPLIT_CHARACTERS);
			_memPointLod params [
				["_memPoint", ""],
				["_lod", "memory"]
			];

			private _turrOffsetsStr = _logic getVariable ["cameraTurretsCustom", "this"];
			private _turrOffsets = [_logic, _turrOffsetsStr, _mainObj] call _proccessArrayString;
			if (isNil "_turrOffsets") then {
				_turrOffsets = [];
			};
			if (_checkPointParams && {_turrOffsets isEqualTo []}) exitWith {[]};
			private _turrParams = [
				MGVAR [LGVAR ["cameraObject", ""], objNull],
				BOOL("cameraCanMoveCamera", 1),
				[_logic, (LGVAR ["zoomParams", ""]), objNull] call _proccessArrayString,
				[BOOL("cameraHasNvg", 1), BOOL("cameraHasTI", 1)],
				_turrOffsets,
				true,
				LGVAR ["cameraName", ""],
				BOOL("cameraSmoothZoom", 1)
			];
			private _turretIndexStr = trim (LGVAR ["turretIndex", ""]);
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

	// ------- OPERATOR OBJECTS AND CLASSES PARAMS ---------
		private _syncedObjs = (synchronizedObjects _logic);
		private _operatorsStr = LGVAR ["cameraObject", ""];
		private _operatorClasses = [];
		private _argumentsNotProccessed = [];
		private ["_class", "_op"];
		private _objectCondition = {(_this isKindOf "Land") || (_this isKindOf "Air")};
		private _operators = (_syncedObjs + (_operatorsStr splitString SPLIT_CHARACTERS)) select {
			call {
				if (_x isEqualType objNull) exitWith {
					_x call _objectCondition;
				};
				if (("""" in _x) || ("'" in _x)) then {
					comment "Classnames (strings)";
					_class = call compile _x;
					if (isNil "_class") exitWith {
						_argumentsNotProccessed pushBack _x;
						false; 
					};
					_operatorClasses pushBackUnique _class;
					false; 
				} else {
					_op = missionNamespace getVariable _x;
					if ((isNil "_op") || {!(IS_OBJ(_op))}) then {
						_argumentsNotProccessed pushBack _x;
						false;
					} else {
						_op call _objectCondition;
					};
				};
			};
		};
		private _hasNoOperatorObjs = _operators isEqualTo [];
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

		private _nvgTi = [SELECT_DEF("cameraHasNvg", 1), SELECT_DEF("cameraHasTI", 1)];

		private _name = LGVAR ["cameraName", ""];
		private _canMoveCam = SELECT_DEF("cameraCanMoveCamera", 1);
		private _smoothZoom = BOOL("cameraSmoothZoom", 1);
	// ---------------------------------------

	// -------- PROCCESS OPERATOR CLASSES --------
		if !(_operatorClasses isEqualTo []) then {
			private _turretsCustom = [[_logic, LGVAR ["cameraTurretsCustom", "this"]] call _proccessArrayString];
			(_operatorClasses + [
				_sides,
				_turretsCustom,
				_nvgTi,
				_name,
				[
					_canMoveCam,
					_smoothZoom
				]
			]) call CFM_fnc_setOperator;
		};
	// ---------------------------------------

	// ------ PROCCESS IF STATIC CAMERA --------
	if (_operators isEqualTo []) exitWith {
		[_logic] call CFM_fnc_initModuleStaticCamera;
	};
	// ---------------------------------------

	// --- PROCCESS OPERATORS OBJECTS AND TURRET MODULES ---
		private _staticCamModuleClass = (tolower "CFM_Module_Camera");
		private _syncedTurretModules = _syncedObjs select {(tolower typeOf _x) isEqualTo _staticCamModuleClass};
		private _memPointLodStr = _logic getVariable ["cameraMemoryPoint", ""];

		private _memPointLod = _memPointLodStr splitString (trim SPLIT_CHARACTERS);
		_memPointLod params [
			["_memPoint", ""],
			["_lod", "memory"]
		];
		private _mainObject = _operators param [0, objNull];
		private _turretsCustom = [];
		// get the offset of main module
		private _turretParamsMain = [_logic, _mainObject, true] call _proccessTurretModule;
		if !(_turretParamsMain isEqualTo []) then {
			_turretsCustom pushBack _turretParamsMain;
		};
		{
			private _turretModuleParams = [_x, _mainObject, true] call _proccessTurretModule;
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

