/*
    Function: CFM_fnc_setR2TTexture
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params["_monArg", ["_render", true], ["_r2t", ""], ["_turnOff", false]];
(RESOLVE_MON(_monArg)) params ["_monitor", "_instId"];
if (!(IS_OBJ(_monitor)) || {_instId < 1}) exitWith {false};
private _dhId = MON_GVAR(_monitor, _instId, "CFM_displayHandlerId", -1);
if (_dhId < 1) exitWith {false};
["setR2TTexture", [_render, _r2t, _turnOff]] CALL_DH_INST(_monitor, _dhId);
