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

private _allVehConfigClasses = (("true" configClasses (configFile >> "CfgVehicles") apply {toLower (configName _x)}) select {_c = _x; (["Man", "Land", "Air"] findIf {_c isKindOf _x}) != -1});
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
				if ((_y#0) isEqualTo DEF_MEM_POINT) then {
					_y set [0, ([_cls, _x, _type] call CFM_fnc_getCameraPoints)#1]
				};
			} forEach _params;
			_pointSet set [_x, _params];
		} forEach _fitClasses;
	} else {
		{
			if ((_y#0) isEqualTo DEF_MEM_POINT) then {
				_y set [0, ([_cls, _x, _type] call CFM_fnc_getCameraPoints)#1]
			};
		} forEach _params;
		_pointSet set [_cls, _params];
	};
} forEach _defaults;

parsingNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSet];
_pointSet
