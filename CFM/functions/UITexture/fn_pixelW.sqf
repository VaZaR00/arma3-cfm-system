/*
    Function: CFM_fnc_pixelW
    Author: Vazar
    Description:
        Returns single pixel (or N pixels) width in [0..1] display coordinate space for the monitor's ScreenResolution.
*/

#include "defines.hpp"

private _val = if (_this isEqualType 0) then {_this} else {_this param [0, 1]};
private _context = if (_this isEqualType []) then {_this param [1, displayNull]} else {displayNull};
private _res = if ((_context isEqualType []) && {count _context >= 2} && {(_context select 0) isEqualType 0}) then {
	_context
} else {
	[_context] call CFM_fnc_getMonitorScreenResolution
};
private _resW = (_res param [0, DEFAULT_UI_SIZE_W]) max 1;

_val / _resW
