/*
    Function: CFM_fnc_setMonitorPiPEffect
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monitor", ["_pipEffect", 0]];
if !(_pipEffect isEqualType 0) exitWith {false};
private _renderTarget = _monitor getVariable ["CFM_monitorR2Tid", "rendertarget0"];
_renderTarget setPiPEffect [_pipEffect];
_monitor setVariable ["CFM_currentPiPEffect", _pipEffect];
true
