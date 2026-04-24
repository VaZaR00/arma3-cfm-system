/*
    Function: CFM_fnc_compareVectors
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_v1", []], ["_v2", []], ["_tolerance", DO_INTERPOLATE_TOLERANCE]];

if (_tolerance <= 0) exitWith {
	_v1 isEqualTo _v2
};

private _dist = _v1 distance _v2;

(_dist) < _tolerance
