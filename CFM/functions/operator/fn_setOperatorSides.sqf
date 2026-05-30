/*
    Function: CFM_fnc_setOperatorSides
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator", ["_sides", civilian], ["_global", true]];
["setOperatorSides", [_sides, _global], false] SPAWN_OBJCLASS("Operator", _operator);
