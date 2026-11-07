/*
    Function: CFM_fnc_height
    Author: Vazar
    Description:
        Calculates dynamic UI height (and text size) in [0..1] display coordinate space for a given grid unit count
        based on the current monitor's ScreenResolution height.
*/

#include "defines.hpp"

private _val = if (_this isEqualType 0) then {_this} else {_this param [0, 1]};
private _scale = if (_this isEqualType []) then {_this param [1, DEFAULT_UI_GRID_SCALE]} else {DEFAULT_UI_GRID_SCALE};
private _res = uiNamespace getVariable ["CFM_currentUiResolution", missionNamespace getVariable ["CFM_currentUiResolution", DEFAULT_SCREEN_RESOLUTION]];
private _resH = (_res param [1, DEFAULT_UI_SIZE_H]) max 1;

_val * (_scale * (1 / _resH) * 2)
