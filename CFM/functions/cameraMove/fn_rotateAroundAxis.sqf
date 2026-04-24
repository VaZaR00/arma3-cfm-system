/*
    Function: CFM_fnc_rotateAroundAxis
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params ["_v", "_axis", "_angle"];
private _c = cos _angle;
private _s = sin _angle;
(_v vectorMultiply _c) vectorAdd
((_axis vectorCrossProduct _v) vectorMultiply _s) vectorAdd
(_axis vectorMultiply ((_axis vectorDotProduct _v) * (1 - _c)))
