/*
    Function: CFM_fnc_posY
    Author: Vazar
    Description:
        Calculates Y coordinate in [0..1] display coordinate space from grid units (with optional origin offset).
*/

#include "defines.hpp"

private _val = if (_this isEqualType 0) then {_this} else {_this param [0, 0]};
private _origin = if (_this isEqualType []) then {_this param [1, 0]} else {0};

_origin + (_val call CFM_fnc_height)
