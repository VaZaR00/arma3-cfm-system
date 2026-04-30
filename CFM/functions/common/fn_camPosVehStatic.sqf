/*
    Function: CFM_fnc_camPosVehStatic
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_offsets", []]];

// _offsets: [_pos, [_dir, _up]]

_offsets params [["_offsetPos", NULL_VECTOR], ["_vdup", [NULL_VECTOR, NULL_VECTOR]]];
_vdup params [["_odir", NULL_VECTOR], ["_oup", NULL_VECTOR]];

private _dir = _obj vectorModelToWorldVisual _odir;
private _up = _obj vectorModelToWorldVisual _oup;
private _pos = _obj modelToWorldVisualWorld _offsetPos;

[_pos, _dir, _up]