/*
    Function: CFM_fnc_posX
    Author: Vazar
    Description:
        Calculates X coordinate in [0..1] display coordinate space from grid units (with optional origin offset),
        resolved via _this = [display].
*/

#include "defines.hpp"

private _val = if (_this isEqualType 0) then {_this} else {_this param [0, 0]};
private _context = if (_this isEqualType []) then {_this param [1, displayNull]} else {displayNull};
private _origin = 0;
if (_context isEqualType 0) then {
	_origin = _context;
	_context = _this param [2, displayNull];
};

_origin + ([_val, _context] call CFM_fnc_width)
