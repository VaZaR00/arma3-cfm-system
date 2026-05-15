/*
    Function: CFM_fnc_getDefaultPointAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_objClass", ["_turrIndex", -1]];

private _pointSet = missionNamespace getVariable ["CFM_classesPointAlignmentSet", createHashMap];

private _predefinedAlignment = _pointSet get _objClass;

if ((isNil "_predefinedAlignment") || {(_predefinedAlignment isEqualTo [])}) then {
	_predefinedAlignment = createHashMap;
};
if !(_predefinedAlignment isEqualType createHashMap) then {
	_predefinedAlignment = createHashMapFromArray _predefinedAlignment;
};
if ((isNil "_predefinedAlignment") || {!(_predefinedAlignment isEqualType createHashMap)}) then {
	_predefinedAlignment = createHashMap;
};

private _predefinedAlignmentTurr = _predefinedAlignment getOrDefault [_turrIndex, []];

if (_predefinedAlignmentTurr isEqualType []) then {_predefinedAlignmentTurr} else {[]};
