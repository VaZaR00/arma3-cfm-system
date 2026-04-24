/*
    Function: CFM_fnc_initDefaultPointsAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];

private _vehConfigClasses = (("true" configClasses (configFile >> "CfgVehicles") apply {toLower (configName _x)}) select {_c = _x; (["Man", "Land", "Air"] findIf {_c isKindOf _x}) != -1});

// default offset for vehs is [-0.3, 0.0, 0.2] in CFM_fnc_getCameraPoints
private _defaults = [
	[["t72", "bmd2", "bmd1"], [[-1, [[-0.5,-0.8,0.3]]]]],
	[["bmp2"], [[-1, [[-0.8,0.3,0.2]]]]],
	[["bmp1"], [[-1, [[-0.3,0.45,0.7]]]]],
	[["t80", "t90"], [[-1, [[-0.5,-0.6,0.3]]]]],
	[["btr", "brdm"], [[-1, [[-0.2,0.1,0.1]]]]],
	[["m1a2"], [[-1, [[-0.8,-0.2,0.8]]]]],
	[["fpv", "crocus"], [[-1, [[0.0, 0.2, 0.1]]]]]
];
{
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
			_pointSet set [_x, _params];
		} forEach _fitClasses;
	} else {
		_pointSet set [_cls, _params];
	};
} forEach _defaults;

missionNamespace setVariable ["CFM_classesPointAlignmentSet", _pointSet];
_pointSet
