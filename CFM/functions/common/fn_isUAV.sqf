/*
    Function: CFM_fnc_isUAV
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

(_this isKindOf "Air") && {(getNumber (configFile >> "CfgVehicles" >> (typeOf _this) >> "isUav")) isEqualTo 1}
