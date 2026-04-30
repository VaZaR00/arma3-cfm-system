/*
    Function: CFM_fnc_initDefaultPointsAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

#define DEF_MEM_POINT "-def-"

private _defaultPresetArray = 
#include "..\other\defaultAlignmentsPresetVTG.sqf"
;
private _defaultPreset = createHashMap;
{
	_defaultPreset set [_x#0, createHashMapFromArray (_x#1)];
} forEach _defaultPresetArray;

private _pointSet = parsingNamespace getVariable ["CFM_classesPointAlignmentSet", _defaultPreset];

private _allVehConfigClasses = (("true" configClasses (configFile >> "CfgVehicles") apply {toLower (configName _x)}) select {_c = _x; (["LandVehicle", "Air"] findIf {_c isKindOf _x}) != -1});
parsingNamespace setVariable ["CFM_allVehConfigClasses", _allVehConfigClasses];
private _vehConfigClasses = _allVehConfigClasses select {!(_x in _pointSet)};

// default offset for vehs is [-0.3, 0.0, 0.2] in CFM_fnc_getCameraPoints
private _defaults = [
	/* 
		[
			class:
				1. string
				2. [string, string, ...]]
				3. [type, classes] // type for CFM_fnc_getCameraPoints
			[
				// turrets params
				[
					turretIndex,
					1 for CFM_fnc_camPosVehTurret: [_memPoint, [_addArr, [_dir, _up], _setArr]]
						- _memPoint: if "-def-" it will get mem point from CFM_fnc_getCameraPoints
					2 for CFM_fnc_camPosVehStatic: [_pos, [_dir, _up]]
					3 for CFM_fnc_camPosStatic: [_pos, _dir, _up]
				],
				...
			]
		] 
	*/
	[["t72", "bmd2", "bmd1"], [[-1, [DEF_MEM_POINT, [[-0.5,-0.8,0.3]]]]]],
	[["bmp2"], [[-1, [DEF_MEM_POINT, [[-0.8,0.3,0.2]]]]]],
	[["bmp1"], [[-1, [DEF_MEM_POINT, [[-0.3,0.45,0.7]]]]]],
	[["t80", "t90"], [[-1, [DEF_MEM_POINT, [[-0.5,-0.6,0.3]]]]]],
	[["btr", "brdm"], [[-1, [DEF_MEM_POINT, [[-0.2,0.1,0.1]]]]]],
	[["m1a2"], [[-1, [DEF_MEM_POINT, [[-0.8,-0.2,0.8]]]]]],
	[["fpv", "crocus"], [[-1, [[0.0, 0.2, 0.1]]]]]
];

private _defaultMemPointF = {
	params["_p", ["_index", _x]];
	if ((_p#0) isEqualTo DEF_MEM_POINT) then {
		private _defCamPoints = [_cls, _index, _type] call CFM_fnc_getCameraPoints;
		if (_defCamPoints isEqualTo []) exitWith {[]};
		private _defPointParams = (_defCamPoints)#1;
		if !(_defPointParams isEqualType []) then {_defPointParams = [_defPointParams]};
		_defPointParams params [["_memPoint", ""], ["_offsetDef", []]];
		_p set [0, _memPoint];
		if ((_offsetDef isEqualType []) && {(count _offsetDef == 3)}) then {
			private _alignment = _p param [1, [], [[]]];
			private _offset = _alignment param [0, []];
			if !((_offset isEqualType []) && {(count _offset == 3)}) then {
				_alignment set [0, _offsetDef];
			};
			_p set [1, _alignment];
		};
	};
	_p
};

private _proccessed = [];
{
	private _type = TYPE_VEH;
	private _checkClasses = false;
	private _cls = (_x#0);
	if (_cls isEqualType []) then {
		_checkClasses = true;
		_cls = _cls apply {toLower _x};
	} else {
		_cls = toLower _cls;
	};
	private _params = createHashMapFromArray (_x#1);
	if (_checkClasses) then {
		private _fitClasses = _vehConfigClasses select {private _c = _x; (_cls findIf {_x in _c}) != -1};
		{
			private _cls = _x;
			{
				[_y] call _defaultMemPointF;
			} forEach _params;
			_proccessed pushBack _cls;
			_pointSet set [_cls, _params];
		} forEach _fitClasses;
	} else {
		{
			[_y] call _defaultMemPointF;
		} forEach _params;
		_proccessed pushBack _cls;
		_pointSet set [_cls, _params];
	};
} forEach _defaults;

private _type = TYPE_VEH;
{
	private _cls = _x;

	if (_cls in _proccessed) then {continue};

	private _paramsArr = ([-1, 0] apply {[_x, [[DEF_MEM_POINT], _x] call _defaultMemPointF]});
	private _params = createHashMapFromArray (_paramsArr select {!((_x#1) isEqualTo [])});

	_pointSet set [_cls, _params];
	_proccessed pushBack _cls;
} forEach _vehConfigClasses;

parsingNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSet];
_pointSet
