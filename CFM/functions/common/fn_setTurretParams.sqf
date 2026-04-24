/*
    Function: CFM_fnc_setTurretParams
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_operator", objNull]];
_this = _this - [_operator];
["setTurretParams", _this] CALL_OBJCLASS("Operator", _operator);
