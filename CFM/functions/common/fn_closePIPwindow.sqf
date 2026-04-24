/*
    Function: CFM_fnc_closePIPwindow
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_player", PLAYER_]];
private _renderTarget = _player getVariable ["CFM_currentRscLayer", ""];
_renderTarget cutFadeOut 0;
private _prevDisplay = _player getVariable ["CFM_currentDisplay", displayNull];
if (!isNull _prevDisplay) then { _prevDisplay closeDisplay 1; };
