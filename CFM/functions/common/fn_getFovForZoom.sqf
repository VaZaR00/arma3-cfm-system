/*
    Function: CFM_fnc_getFovForZoom
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_zoom"];

if !(_zoom isEqualType 1) exitWith {1};

1 / _zoom;
