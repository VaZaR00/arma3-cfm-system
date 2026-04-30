/*
    Function: CFM_fnc_memoryPointAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_memPoint", ""], ["_pointParams", "", [[], ""]]];

_pointParams params [["_addArr", [0,0,0]], ["_dirUp", []], ["_setArr", [-1,-1,-1]]];

private _offset = [_obj, [_memPoint, "Memory"], _addArr, _dirUp] call CFM_fnc_getMemPointOffsetInModelSpace;

private _selPos = _offset param [0, [0,0,0]];

for "_i" from 0 to 2 do {
	private _set = _setArr#_i;
	if (_set isEqualTo -1) then {continue};
	_selPos set [_i, _set];
};
[_selPos, _offset param [1, [[0,1,0], [0,0,1]]]]
