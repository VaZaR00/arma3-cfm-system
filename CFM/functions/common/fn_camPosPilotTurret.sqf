/*
    Function: CFM_fnc_camPosPilotTurret
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_obj", objNull]];

private _pos = _obj modelToWorldVisualWorld (getPilotCameraPosition _obj);
private _camDir = _obj vectorModelToWorldVisual (getPilotCameraDirection _obj);
private _camDirPos = ((vectorNormalized _camDir) vectorMultiply 1) vectorAdd _pos;
private _fromToVUP = [_pos, _camDirPos] call BIS_fnc_findLookAt;
private _dir = _fromToVUP#0;
private _up = _fromToVUP#1;

[_pos, _dir, _up]
