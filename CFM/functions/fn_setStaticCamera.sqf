/*
	Name: CFM_fnc_setStaticCamera

	Call: spawn

	Description: 
		Sets satic camera at position and with direction

	Return: true os succes, false or any if not

	Arguments:
		1. _name:str
		2. _posAndOffsetsTurrets:
			{turr param} or
			[{turr param}, ...]
			turr param: [offset:[_pos:vector, _vDirUp:[vector, vector]], (_turretIndex:int), (_zoomTable), (_nvgAndTi)]
		3. _sides:[Array[side], side] - defines sides of monitors which can connect to operator
		4. _obj:[object] - camera/operator object, if none dummy will be created and used as operator
		5. _hasTInNvg - array of [bool, bool] if operator has nvg and ti
		6. _params [array]:
			1. canMoveCameraByDefault [bool] - if true, operator can move camera by default, if false, can't, if not set, it will be set based on turret params (def: false)
			2. smoothZoomDefault [bool] - if true, camera zooms smoothly by default, if false, it doesn't, if not set, it will be set based on turret params (def: false)

	Examples:
		1. One turret
			["Cam1", [
				// first turret params
				[
					[
						[14711.3,16402.5,22.8514], // pos
						[ 
							[0.110442,0.931796,-0.345782], // dir
							[0.0406993,0.343379,0.938314] // up
						]
					]
					// ... other turr params
				],
				// other turrets params
				[] 
			], [west], nil, nil, [[50,50,50,50]]] call CFM_fnc_setStaticCamera;
		2. Multiple turrets (shared params)
			["Cam1", [
				// first turret params
				[
					[
						// first turret offset
						[
							[14711.3,16402.5,22.8514], // pos
							[ 
								[0.110442,0.931796,-0.345782], // dir
								[0.0406993,0.343379,0.938314] // up
							]
						],
						// second turret offset
						[
							[14723.9,16399.4,23.7425], // pos
							[
								[-0.592465,0.692964,-0.410901], // dir
								[-0.267031,0.312325,0.911671] // up
							]
						]
					]
					// ... 2 turrets shared params
				],
				// other turrets params
				[] 
			], [west], nil, nil, [[50,50,50,50]]] call CFM_fnc_setStaticCamera;
*/


#include "defines.hpp"

// for JIP sync
if !(isServer) exitWith {false};

if !(canSuspend) exitWith {
	_this spawn CFM_fnc_setStaticCamera;
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
if (_posAndOffsetsTurrets isEqualTo []) exitWith {false};
if !((_posAndOffsetsTurrets#0) isEqualType []) exitWith {false};
if ((_posAndOffsetsTurrets#0#0) isEqualType 1) then {
	_posAndOffsetsTurrets = [_posAndOffsetsTurrets];
};


if (!(_name isEqualType "") || {_name isEqualTo ""}) then {
	_name = "Camera";
};

private _hasDummyObj = IS_OBJ(_dummyObj);
private _turrParams = [];
private _turrs = [];
private _lastPos = [0,0,0];
private _lastTurrIndex = -1;

private _proccesTurret = {
	_this params [
		["_offset", []], 
		["_turretObj", objNull], 
		["_canMoveCamera", -1], 
		["_turretIndex", _lastTurrIndex], 
		["_zoomTable", []], 
		["_nvgAndTi", []], 
		["_turrName", _name], 
		["_smoothZoom", -1]
	];
	
	private _offsetPos = _offset param [0, [0], [[]]];
	private _offsetFirstEl = _offsetPos param [0, [0]];
	if (_offsetFirstEl isEqualType []) exitWith {
		// multiple turret offsets (2 example)
		{
			[_x, _turretObj, _canMoveCamera, _turretIndex, _zoomTable, _nvgAndTi, _turrName, _smoothZoom] call _proccesTurret;
		} forEach _offset;
	};
	_offset params [["_pos", [0,0,0], [[]], 3], ["_vDirUp", [], [[]], 2]];
	_vDirUp params [["_dir", [0,0,0], [[]], 3], ["_up", [0,0,0], [[]], 3]];
	if (_turretIndex in _turrs) then {
		_turretIndex = (_turrs select -1) + 1;
	};
	_turrs pushBack _turretIndex;
	if (!_hasDummyObj && {IS_OBJ(_turretObj)}) then {
		_dummyObj = _turretObj;
	};
	_lastPos = +_pos;
	private _turrArgs = [_turretIndex, [_turretObj, _canMoveCamera, _zoomTable, _nvgAndTi, [_pos, _dir, _up], false, DO_INTERPOLATE_STATIC_CAMS, _turrName, _smoothZoom]];
	_turrParams pushBack _turrArgs;
};

{_x call _proccesTurret} forEach _posAndOffsetsTurrets;

if !(IS_OBJ(_dummyObj)) then {
	_dummyObj = ["createDummyForStaticCam"] CALL_CLASS("DbHandler");
	_dummyObj setPosASL _lastPos;
};

if ((isNil "_dummyObj") || {!IS_OBJ(_dummyObj)}) exitWith {
	"CFM_fnc_setStaticCamera ERROR: can't create dummyObj" WARN;
	false
};

private _args = [_dummyObj, _sides, _turrParams, _hasTInNvg, _name, _params];

_args call CFM_fnc_setOperator;

true