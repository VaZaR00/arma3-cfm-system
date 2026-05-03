/*
    Function: CFM_fnc_memoryPointAlignment
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_memPoint", ""], ["_pointParams", "", [[], ""]], ["_lod", "Memory"]];

_pointParams params [["_addArr", [0,0,0]], ["_dirUp", []], ["_setArr", [-1,-1,-1]]];
_dirUp params [["_dir", DEF_DIR], ["_up", DEF_UP]];

private _memPointDirUp = _obj selectionVectorDirAndUp [_memPoint, _lod];
_memPointDirUp params [["_mdir", DEF_DIR], ["_mup", DEF_UP]];

private _newdirUp = [_mdir vectorAdd _dir, _mup vectorAdd _up];
private _newDirUp = [_memPointDirUp, _dirUp] call CFM_fnc_translateLocalVectors;

private _selPos = [_obj, [_memPoint, _lod], _addArr] call CFM_fnc_getMemPointOffsetInModelSpace;

for "_i" from 0 to 2 do {
	private _set = _setArr#_i;
	if (_set isEqualTo -1) then {continue};
	_selPos set [_i, _set];
};
[_selPos, _newdirUp]
