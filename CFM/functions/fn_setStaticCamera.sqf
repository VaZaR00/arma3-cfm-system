/*
	Name: CFM_fnc_setStaticCamera

	Description: 
		Sets satic camera at position and with direction

	Return: true os succes, false or any if not

	Arguments:
		1. _name:str
		2. _posAndOffsetsTurrets:
			A. One turr param: [_pos:vector, _vDirUp:[vector, vector], (_turretIndex:int), (_zoomTable), (_nvgAndTi)]
			B. [{turr param}, ...]
		3. _obj:[object] - camera/operator object, if none dummy will be created and used as operator
		4. _sides:[Array[side], side] - defines sides of monitors which can connect to operator
		5. _hasTInNvg - array of [bool, bool] if operator has nvg and ti
		6. _params - other
*/


#include "defines.hpp"

private _code = {

params [
	["_name", ""],
	["_posAndOffsetsTurrets", []], 
	["_dummyObj", objNull],
	["_sides", [civilian]], 
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
	_x params [["_pos", [0,0,0], [[]], 3], ["_vDirUp", [], [[]], 2], ["_turretObj", objNull], ["_turretIndex", -2], ["_zoomTable", []], ["_nvgAndTi", []], ["_turrName", _name]];
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
	private _turrArgs = [_turretIndex, [_zoomTable, _nvgAndTi, [_pos, _dir, _up], false, false, _turrName]];
	_turrParams pushBack _turrArgs;
} forEach _posAndOffsetsTurrets;

if !(IS_OBJ(_dummyObj)) then {
	_dummyObj = ["createDummyForStaticCam"] CALL_CLASS("DbHandler");
	_dummyObj setPosASL _lastPos;
};

if ((isNil "_dummyObj") || {!IS_OBJ(_dummyObj)}) exitWith {
	WARN "CFM_fnc_setStaticCamera ERROR: can't create dummyObj";
	false
};

private _args = [_dummyObj, _sides, _turrParams, _hasTInNvg, _name];

_args call CFM_fnc_setOperator;
};

#ifdef SET_MON_OP_REMOTE_EXEC
	// for JIP sync
	if !(isServer) exitWith {false};

	[_this, _code, 0, true, true] call CFM_fnc_remoteExec;
#endif 
#ifndef SET_MON_OP_REMOTE_EXEC
	_this call _code
#endif 