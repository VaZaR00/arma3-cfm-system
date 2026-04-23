/*
	Name: CFM_fnc_setStaticCamera

	Call: spawn

	Description: 
		Sets satic camera at position and with direction

	Return: true os succes, false or any if not

	Arguments:
		1. _name:str
		2. _posAndOffsetsTurrets:
			A. One turr param: [_pos:vector, _vDirUp:[vector, vector], (_turretIndex:int), (_zoomTable), (_nvgAndTi)]
			B. [{turr param}, ...]
		3. _sides:[Array[side], side] - defines sides of monitors which can connect to operator
		4. _obj:[object] - camera/operator object, if none dummy will be created and used as operator
		5. _hasTInNvg - array of [bool, bool] if operator has nvg and ti
		6. _params [array]:
			1. canMoveCameraByDefault [bool] - if true, operator can move camera by default, if false, can't, if not set, it will be set based on turret params (def: false)
			2. smoothZoomDefault [bool] - if true, camera zooms smoothly by default, if false, it doesn't, if not set, it will be set based on turret params (def: false)

*/


#include "defines.hpp"

// for JIP sync
if !(isServer) exitWith {false};

if !(canSuspend) exitWith {
	_this spawn CFM_fnc_setMonitor;
};
waitUntil { !(isNil "CFM_inited") };

params [
	["_name", ""],
	["_posAndOffsetsTurrets", []], 
	["_sides", [civilian]], 
	["_dummyObj", objNull],
	["_hasTInNvg", [0, 0]], 
	["_params", []]
];

if !(_posAndOffsetsTurrets isEqualType []) exitWith {false};

private _isOnePos = (_posAndOffsetsTurrets#0#0) isEqualType 1;

if (_isOnePos) then {
	_posAndOffsetsTurrets = [_posAndOffsetsTurrets];
};

if (!(_name isEqualType "") || {_name isEqualTo ""}) then {
	_name = "Camera";
};

private _hasDummyObj = IS_OBJ(_dummyObj);
private _turrParams = [];
private _turrs = [];
private _lastPos = [0,0,0];
{
	_x params [["_pos", [0,0,0], [[]], 3], ["_vDirUp", [], [[]], 2], ["_turretObj", objNull], ["_canMoveCamera", -1], ["_turretIndex", -2], ["_zoomTable", []], ["_nvgAndTi", []], ["_turrName", _name], ["_smoothZoom", -1]];
	_vDirUp params [["_dir", [0,0,0], [[]], 3], ["_up", [0,0,0], [[]], 3]];
	if (_turretIndex in _turrs) then {
		private _lastTurrIndex = _turrs select -1;
		_turretIndex = _lastTurrIndex + 1;
	};
	if (_turretIndex == -2) then {
		_turretIndex = -1;
		_turrs pushBack -1;
	};
	if (!_hasDummyObj && {IS_OBJ(_turretObj)}) then {
		_dummyObj = _turretObj;
	};
	_lastPos = +_pos;
	private _turrArgs = [_turretIndex, [_turretObj, _canMoveCamera, _zoomTable, _nvgAndTi, [_pos, _dir, _up], false, DO_INTERPOLATE_STATIC_CAMS, _turrName, _smoothZoom]];
	_turrParams pushBack _turrArgs;
} forEach _posAndOffsetsTurrets;

if !(IS_OBJ(_dummyObj)) then {
	_dummyObj = ["createDummyForStaticCam"] CALL_CLASS("DbHandler");
	_dummyObj setPosASL _lastPos;
};

if ((isNil "_dummyObj") || {!IS_OBJ(_dummyObj)}) exitWith {
	"CFM_fnc_setStaticCamera ERROR: can't create dummyObj" WARN;
	false
};

private _args = [_dummyObj, _sides, _turrParams, _hasTInNvg, _name, _params];

[_args, {_this call CFM_fnc_setOperator}, 0, true, true] call CFM_fnc_remoteExec;

true