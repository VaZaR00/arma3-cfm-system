/*
    Function: CFM_fnc_camPosVehStatic
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_offsets", []]];

// _offsets: [_pos, [_dir, _up]]

_offsets params [["_offsetPos", NULL_VECTOR], ["_vdup", []]];
_vdup params [["_odir", DEF_DIR], ["_oup", DEF_UP]];

private _dir = _obj vectorModelToWorldVisual _odir;
private _up = _obj vectorModelToWorldVisual _oup;
private _pos = _obj modelToWorldVisualWorld _offsetPos;

LOGH [_obj, _dir, _odir];

[_pos, _dir, _up]