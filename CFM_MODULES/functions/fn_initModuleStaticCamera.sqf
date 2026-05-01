#include "defines.h"

#define LGVAR _logic GV 
#define BOOL(var, def) ((LGVAR [var, def]) isEqualTo 1)
#define OBJ_BOOL(obj, var, def) ((obj getVariable [var, def]) isEqualTo 1)

private _logic = [_this,0,objNull,[objNull]] call BIS_fnc_param;
private _units = [_this,1,[],[[]]] call BIS_fnc_param;
private _activated = [_this,2,true,[true]] call BIS_fnc_param;

if !(_activated) exitWith {};
if (is3DEN) exitWith {};

[_logic] spawn {
	params["_logic"];

	private _isJustTurret = BOOL("isCameraTurret", 0);

	if (_isJustTurret) exitWith {};

	sleep 0.1;	

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

	if (_sides isEqualTo []) exitWith {
		format["CFM_fnc_initModuleOperator: NO SIDES GIVEN. Side string: %1", _sidesStr] WARN
	};

	private _proccessArrayString = {
		params["_l", "_offsetsStr", ['_isOffset', true]];
		private _res = [];
		private _isThis = (_offsetsStr isEqualTo "this");
		if (_isOffset && {_isThis}) then {
			_res = [getPosASL _l, [vectorDir _l, vectorUp _l]];
		};
		if (!_isThis && {!(_offsetsStr isEqualTo "")}) then {
			_res = call compile _offsetsStr;
		};
		if (isNil "_res") then {
			_res = [];
		};
		if (_res isEqualTo []) exitWith {[]};
		[+_res]
	};
	private _proccessCameraParams = {
		params["_logic"];

		private _name = LGVAR ["cameraName", ""];

		if (_name isEqualTo "") then {
			// generate ID
			private _hash = hashValue _logic;
			private _nums = toArray _hash;
			private _num = 0;
			_nums apply {_num = _num + _x};
			_num = _num * (_nums#0);
			_name = "Camera ID: " + str _num;
		};

		private _camObj = MGVAR [LGVAR ["cameraObject", ""], objNull];
		private _hasNvg = BOOL("cameraHasNvg", 1);
		private _hasTi = BOOL("cameraHasTI", 1);
		private _canMoveCam = (toLower (trim (LGVAR ["cameraCanMoveCamera", ""]))) call {
			if (_this isEqualTo "true") exitWith {true};
			private _canMoveCamArr = _this splitString SPLIT_CHARACTERS;
			_canMoveCamArr = _canMoveCamArr apply {parseNumber _x};
			if (_canMoveCamArr isEqualTo []) exitWith {false};
			_canMoveCamArr resize [4, 0];
			_canMoveCamArr
		};
		private _smoothZoom = BOOL("cameraSmoothZoom", 1);
		private _turretIndex = parseNumber (LGVAR ["turretIndex", ""]);
		private _zoomParamsStr = (LGVAR ["zoomParams", ""]);
		private _zoomParams = [_logic, _zoomParamsStr, false] call _proccessArrayString;

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

	private _offsetsStr = LGVAR ["cameraTurretsCustom", "this"];
	private _offsets = [_logic, _offsetsStr] call _proccessArrayString;
	if (isNil "_offsets") then {
		_offsets = [];
	};
	_offsets = [_offsets];

	private _staticCamModuleClass = (tolower "CFM_Module_Camera");
	private _syncedModules = (synchronizedObjects _logic) select {(tolower typeOf _x) isEqualTo _staticCamModuleClass};

	{
		// skip if its not set as turret
		if !(OBJ_BOOL(_x, "isCameraTurret", 0)) then {continue};

		private _turrOffsetsStr = _x getVariable ["cameraTurretsCustom", "this"];
		private _turrOffsets = [_x, _turrOffsetsStr] call _proccessArrayString;
		if (isNil "_turrOffsets") then {
			_turrOffsets = [];
		};
		private _turrParams = _x call _proccessCameraParams;
		private _turrArgs = [_turrOffsets] + _turrParams;
		_offsets pushBack _turrArgs;
	} forEach _syncedModules;

	if (_offsets isEqualTo []) exitWith {
		format["CFM_fnc_initModuleCamera: ZERO OFFSETS GIVEN. Offset string: '%1'. Synced modules: '%2'", _offsetsStr, _syncedModules] WARN
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

