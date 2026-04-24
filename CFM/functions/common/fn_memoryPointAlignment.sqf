/*
    Function: CFM_fnc_memoryPointAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_memPoint", ""], ["_pointParams", "", [[], ""]]];

if (_pointParams isEqualType "") exitWith {
	_obj selectionPosition [_pointParams, "Memory"];
};

_pointParams params [["_addArr", [0,0,0]], ["_setArr", [-1,-1,-1]]];
if (count _addArr != 3) then {
	_addArr = +[0,0,0];
};
if (count _setArr != 3) then {
	_setArr = +[-1,-1,-1];
};

private _selPos = [_obj, [_memPoint, "Memory"], _addArr] call CFM_fnc_getMemPointOffsetInModelSpace;

for "_i" from 0 to 2 do {
	private _set = _setArr#_i;
	if (_set isEqualTo -1) then {continue};
	_selPos set [_i, _set];
};
_selPos
