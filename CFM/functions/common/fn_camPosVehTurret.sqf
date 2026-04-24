/*
    Function: CFM_fnc_camPosVehTurret
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_pointParams", []]];

_pointParams params [["_memPoint", ""], ["_alignment", []]];

private _doAlign = !(_alignment isEqualTo []);
private _dirPointPos = if (_doAlign) then {
	[_obj, _memPoint, _alignment] call CFM_fnc_memoryPointAlignment;
} else {
	_obj selectionPosition [_memPoint, "Memory"]
};
private _dirPointVUP = _obj selectionVectorDirAndUp [_memPoint, "Memory"];

private _pos = _obj modelToWorldVisualWorld _dirPointPos;
private _dir = _obj vectorModelToWorldVisual (_dirPointVUP#0);
private _up = _obj vectorModelToWorldVisual (_dirPointVUP#1);

[_pos, _dir, _up]
