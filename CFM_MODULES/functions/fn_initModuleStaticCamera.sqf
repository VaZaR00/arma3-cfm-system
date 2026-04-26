#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	private _isJustTurret = BOOL("isStaticCameraTurret", 0);

	if (_isJustTurret) exitWith {};

	sleep 0.1;	

	private _sidesStr = LGVAR ["cameraSides", ""];
	private _sides = (_sidesStr splitString " ,.;:[](){}") apply {
		private _compile = call compile _x;
		if ((isNil "_compile") || {!(_compile isEqualType west)}) then {
			false
		} else {
			_compile
		};
	};
	_sides = _sides select {_x isEqualType west};

	if (_sides isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %1", _sidesStr] DLOG
	};

	private _proccessArrayString = {
		params["_offsetsStr", ['_isOffset', true]];
		private _res = [];
		private _isThis = (_offsetsStr isEqualTo "this");
		if (_isOffset && {_isThis}) then {
			_res = [[getPosASL _logic, [vectorDir _logic, vectorUp _logic]]];
		};
		if (!_isThis && {!(_offsetsStr isEqualTo "")}) then {
			_res = call compile _offsetsStr;
		};
		if (isNil "_res") then {
			_res = [];
		};
		[+_res]
	};
	private _proccessCameraParams = {
		params["_logic"];

		private _name = LGVAR ["cameraName", ""];

		private _camObj = MGVAR [LGVAR ["cameraObject", ""], objNull];
		private _hasNvg = BOOL("cameraHasNvg", 1);
		private _hasTi = BOOL("cameraHasTI", 1);
		private _canMoveCam = BOOL("cameraCanMoveCamera", 1);
		private _smoothZoom = BOOL("cameraSmoothZoom", 1);
		private _turretIndex = parseNumber (LGVAR ["turretIndex", ""]);
		private _zoomParamsStr = (LGVAR ["zoomParams", ""]);
		private _zoomParams = [_zoomParamsStr, false] call _proccessArrayString;

		[
			_camObj,
			_canMoveCam,
			_turretIndex,
			_zoomParams,
			[_hasNvg, _hasTi],
			_name,
			_smoothZoom
		]
	};

	private _offsetsStr = LGVAR ["cameraPosAndOffsetsTurretsCustom", "this"];
	private _offsets = _offsetsStr call _proccessArrayString;
	if (isNil "_offsets") then {
		_offsets = [];
	};

	private _staticCamModuleClass = (tolower "CFM_Module_StaticCamera");
	private _syncedModules = (synchronizedObjects _logic) select {(tolower typeOf _x) isEqualTo _staticCamModuleClass};

	if !(_syncedModules isEqualTo []) then {
		{
			private _turrOffsetsStr = _x getVariable ["cameraPosAndOffsetsTurretsCustom", "this"];
			private _turrOffsets = _turrOffsetsStr call _proccessArrayString;
			if (isNil "_turrOffsets") then {
				_turrOffsets = [];
			};
			private _turrParams = _logic call _proccessCameraParams;
			private _turrArgs = [[_turrOffsets]] + _turrParams;
			_offsets pushBack _turrArgs;
		} forEach _syncedModules;
	};

	if (_offsets isEqualTo []) exitWith {
		format["CFM_fnc_initModuleStaticCamera: ZERO OFFSETS GIVEN. Offset string: '%1'. Synced modules: '%2'", _offsetsStr, _syncedModules] DLOG
	};

	private _params = _logic call _proccessCameraParams;

	[
		_params param [5, ""],
		_offsets,
		_sides,
		_params param [0, objNull],
		_params param [4, [true, true]],
		[
			_params param [1, -1],
			_params param [6, -1]
		]
	] call CFM_fnc_setStaticCamera;
};

