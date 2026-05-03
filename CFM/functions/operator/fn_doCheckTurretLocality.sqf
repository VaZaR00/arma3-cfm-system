/*
    Function: CFM_fnc_doCheckTurretLocality
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_operator"];

if !(IS_OBJ(_operator)) exitWith {false};

_operator call CFM_fnc_isUAV;
