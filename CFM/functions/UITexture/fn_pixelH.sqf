/*
    Function: CFM_fnc_pixelH
    Author: Vazar
    Description:
        Returns single pixel (or N pixels) height in [0..1] display coordinate space for the current monitor's ScreenResolution.
*/

#include "defines.hpp"

private _val = if (_this isEqualType 0) then {_this} else {_this param [0, 1]};
private _res = uiNamespace getVariable ["CFM_currentUiResolution", missionNamespace getVariable ["CFM_currentUiResolution", DEFAULT_SCREEN_RESOLUTION]];
private _resH = (_res param [1, DEFAULT_UI_SIZE_H]) max 1;

_val / _resH
