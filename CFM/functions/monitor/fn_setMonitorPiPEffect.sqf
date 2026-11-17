/*
    Function: CFM_fnc_setMonitorPiPEffect
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_pipEffect", 0]];
if !(_pipEffect isEqualType 0) exitWith {false};
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _renderTarget = MON_GVAR(_monitor, _instId, "CFM_monitorR2Tid", "rendertarget0");
_renderTarget setPiPEffect [_pipEffect];
MON_SVAR(_monitor, _instId, "CFM_currentPiPEffect", _pipEffect);
true
