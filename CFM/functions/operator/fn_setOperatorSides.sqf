/*
    Function: CFM_fnc_setOperatorSides
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator", ["_sides", civilian]];
["setOperatorSides", [_sides], _operator, false] SPAWN_OBJCLASS("Operator", _operator);
