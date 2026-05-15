/*
    Function: CFM_fnc_getObjCamOffsetMS
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_obj", ["_vectorMS", [0,0,0]], ["_dist", 1]];
private _dir = _obj vectorModelToWorldVisual _vectorMS;
private _pos = getPosASLVisual _obj;
[_pos, _dir, _dist] call CFM_fnc_getPositionByVectors;
