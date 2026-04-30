/*
    Function: CFM_fnc_memoryPointAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_memPoint", ""], ["_pointParams", "", [[], ""]], ["_lod", "Memory"]];

_pointParams params [["_addArr", [0,0,0]], ["_dirUp", []], ["_setArr", [-1,-1,-1]]];
_dirUp params [["_dir", [0,0,0]], ["_up", [0,0,0]]];

private _memPointDirUp = _obj selectionVectorDirAndUp [_memPoint, _lod];
_memPointDirUp params [["_mdir", [0,0,0]], ["_mup", [0,0,0]]];

private _newdirUp = [_mdir vectorAdd _dir, _mup vectorAdd _up];

private _selPos = [_obj, [_memPoint, _lod], _addArr] call CFM_fnc_getMemPointOffsetInModelSpace;

for "_i" from 0 to 2 do {
	private _set = _setArr#_i;
	if (_set isEqualTo -1) then {continue};
	_selPos set [_i, _set];
};
[_selPos, _newdirUp]
