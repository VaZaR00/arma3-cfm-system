/*
    Function: CFM_fnc_camPosGoPro
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj"];
private _headPos = selectionPosition [_obj, "head", 9, true];
private _dirUp = _obj selectionVectorDirAndUp ["head", "memory"];
private _dir = _obj vectorModelToWorldVisual _dirUp#0;
private _up = _obj vectorModelToWorldVisual _dirUp#1;
private _headPos = [_obj, ["head", "memory"], [-0.19, 0.1, 0.25]] call CFM_fnc_getMemPointOffsetInModelSpace;
private _pos = _obj modelToWorldVisualWorld _headPos;

_obj setVariable ["CFM_camPosPoint", GOPRO_MEMPOINT];

[_pos, _dir, _up]
