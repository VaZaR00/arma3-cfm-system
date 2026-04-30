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

	private _syncedObjs = (synchronizedObjects _logic);

	private _mainObject = missionNamespace getVariable [(LGVAR ["operatorObject", ""]), objNull];

	if !(isNil "_mainObject") then {
		if (_mainObject isEqualType objNull) then {
			if !(_mainObject isEqualTo objNull) then {
				_syncedObjs = [_mainObject] + _syncedObjs;
			};
		};
	};
	
	private _operators = _syncedObjs select {
		private _obj = _x;

		if (isNil "_obj") exitWith {false};
		if !(_obj isEqualType objNull) exitWith {false};
		if (isNull _obj) exitWith {false};

		true
	};

	if (_operators isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: ZERO OPERATORS. Synced objects given: %1", _syncedObjs] DLOG
	};

	_mainObject = _operators param [0, objNull];

	private _sidesStr = LGVAR ["operatorSides", ""];
	private _sides = (_sidesStr splitString " ,.;:[](){}") apply {
		private _compile = call compile _x;
		if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
			false
		} else {
			_compile
		};
	};
	_sides = _sides select {_x isEqualType west};

	if (_sides isEqualTo []) then {
		_sides = [side (_operators#0)];
	};

	if (_sides isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %1", _sidesStr] DLOG
	};

	private _turretsCustom = LGVAR ["operatorTurretsCustom", ""];
	if !(_turretsCustom isEqualTo "") then {
		_turretsCustom = call compile _turretsCustom;
	};
	if (isNil "_turretsCustom") then {
		_turretsCustom = [];
	};
	if !(_turretsCustom isEqualType []) then {
		_turretsCustom = [];
	};

	private _staticCamModuleClass = (tolower "CFM_Module_Camera");
	private _syncedModules = (synchronizedObjects _logic) select {(tolower typeOf _x) isEqualTo _staticCamModuleClass};

	private _proccessArrayString = {
		params["_l", "_offsetsStr", ['_isOffset', true]];
		private _res = [];
		private _isThis = ((tolower _offsetsStr) isEqualTo "this");
		if (_isOffset && {_isThis}) then {
			private _relPosModule = _mainObject worldToModelVisual (getPos _l);
			private _relDirModule = _mainObject vectorWorldToModelVisual (vectorDir _l);
			private _relUpModule = _mainObject vectorWorldToModelVisual (vectorUp _l);
			private _memPointPos = _mainObject selectionPosition [_memPoint, _lod];
			private _memPointDirUp = _mainObject selectionVectorDirAndUp [_memPoint, _lod];
			_res = [
				_memPoint, [
					_relPosModule vectorDiff _memPointPos, 
					[
						_relDirModule vectorDiff (_memPointDirUp#0), 
						_relUpModule vectorDiff (_memPointDirUp#1)
					]
				]
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
	{
		private _logic = _x;

		// skip if its not set as turret
		if !(BOOL("isCameraTurret", 0)) then {continue};

		private _memPointLodStr = _x getVariable ["cameraMemoryPoint", ""];

		private _memPointLod = _memPointLodStr splitString " ,.;:[()]";
		_memPointLod params [
			["_memPoint", ""],
			["_lod", "memory"]
		];

		private _turrOffsetsStr = _x getVariable ["cameraPosAndOffsetsTurretsCustom", "this"];
		private _turrOffsets = [_x, _turrOffsetsStr] call _proccessArrayString;
		if (isNil "_turrOffsets") then {
			_turrOffsets = [];
		};
		private _turrParams = [
			MGVAR [LGVAR ["cameraObject", ""], objNull],
			BOOL("cameraCanMoveCamera", 1),
			[_logic, (LGVAR ["zoomParams", ""]), false] call _proccessArrayString,
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
		_turretsCustom pushBack _turrParams;
	} forEach _syncedModules;

	// _pointParams: [_memPoint, ["_addArr", ["_dir", "_up"], "_setArr"]]
	// _turretsCustom: [[turrIndex, [_turretObject, _canMoveCamera, _setZoomTable, _setNvgAndTi, _pointParams, _doInterpolationSet, _turretName, _smoothZoomSetTurr]]]

	private _nvgTi = [SELECT_DEF("operatorHasNvg", 1), SELECT_DEF("operatorHasTI", 1)];

	private _name = LGVAR ["operatorName", ""];
	private _canMoveCam = SELECT_DEF("operatorCanMoveCamera", 1);
	private _smoothZoom = BOOL("operatorSmoothZoom", 1);

	[
		_operators,
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

